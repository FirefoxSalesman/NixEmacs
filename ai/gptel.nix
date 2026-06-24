{
  config,
  lib,
  ...
}:

let
  ai = config.programs.emacs.init.ai;
  keybinds = config.programs.emacs.init.keybinds;
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ai.gptel = {
    enable = lib.mkEnableOption "Enables gptel. Config borrowed from doom. It is strongly reccomended that you read gptel's readme before using this.";

    macher = {
      enable = lib.mkEnableOption "Enables macher, a lightweight agent-like tool built on top of gptel.";
      agent = lib.mkEnableOption "Enables macher-agent for a more agentic workflow.";
    };

    introspection = {
      enable = lib.mkEnableOption "Provides the introspect preset via ragmacs. It allows gptel to read emacs's documentation. Utterly useless if you enable gptel-agent.";
      model = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The model to use for the introspection preset. Must be a model that can do function calls. Uses the current model if left blank.";
      };
    };

    agent.enable = lib.mkEnableOption "Enables gptel-agent.";
  };

  config.programs.emacs.init.usePackage = lib.mkIf ai.gptel.enable {
    gptel = {
      enable = true;
      setopt.gptel-default-mode = lib.mkDefault "'org-mode";
      generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
        "g" = lib.mkDefault '''(:ignore t :which-key "gptel")'';
        "gp" = lib.mkDefault '''("prompt" . gptel)'';
        "gt" = lib.mkDefault '''("add text to context" . gptel-add)'';
        "gf" = lib.mkDefault '''("add file to context" . gptel-add-file)'';
        "gm" = lib.mkDefault '''("open configuration menu" . gptel-menu)'';
        "gr" = lib.mkDefault '''("rewrite current region" . gptel-rewrite)'';
      };
    };

    gptel-org = lib.mkIf ide.languages.org.enable {
      enable = true;
      package = epkgs: epkgs.gptel;
      command = [
        "gptel-org-set-topic"
        "gptel-org-set-properties"
      ];
      generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
        "go" = lib.mkDefault '''("limit context to current org heading" . gptel-org-set-topic)'';
        "gO" = lib.mkDefault '''("store gptel config as org properties" . gptel-org-set-properties)'';
      };
    };

    ob-gptel = lib.mkIf ide.languages.org.enable {
      enable = true;
      config = ''
        (defun ob-gptel-setup-completions ()
              (add-hook 'completion-at-point-functions
                'ob-gptel-capf nil t))
      '';
      hook = [ "(org-mode . ob-gptel-setup-completions)" ];
      babel = "gptel";
    };

    gptel-magit = lib.mkIf ide.magit.enable {
      enable = true;
      after = [ "magit" ];
      ghookf = [ "('magit-mode 'gptel-magit-install)" ];
    };

    gptel-quick = {
      enable = true;
      generalOne.global-leader."ge" = lib.mkIf keybinds.leader-key.enable (
        lib.mkDefault '''("Explain the current region" . gptel-quick)''
      );
    };

    macher = lib.mkIf ai.gptel.macher.enable {
      enable = true;
      command = [ "macher-install" ];
      config = "(macher-install)";
      generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
        "gM" = lib.mkDefault '''(:ignore t :which-key "macher")'';
        "gMi" = lib.mkDefault '''("implement" . macher-implement)'';
        "gMr" = lib.mkDefault '''("revise" . macher-revise)'';
        "gMd" = lib.mkDefault '''("discuss" . macher-discuss)'';
        "gMa" = lib.mkDefault '''("abort" . macher-abort)'';
      };
    };

    macher-agent = lib.mkIf (ai.gptel.macher.enable && ai.gptel.macher.agent) {
      enable = true;
      after = [ "macher" ];
      generalOneConfig.global-leader."gMt" = '''("inject thought" . macher-agent-inject-thought)'';
    };

    ragmacs = lib.mkIf ai.gptel.introspection.enable {
      enable = true;
      after = [ "gptel" ];
      config = ''
        (gptel-make-preset 'introspect
             :pre (lambda () (require 'ragmacs))
             :system
             "You are pair programming with the user in Emacs and on Emacs.

         Your job is to dive into Elisp code and understand the APIs and
         structure of elisp libraries and Emacs.  Use the provided tools to do
         so, but do not make duplicate tool calls for information already
         available in the chat.

         <tone>
         1. Be terse and to the point.  Speak directly.
         2. Explain your reasoning.
         3. Do NOT hedge or qualify.
         4. If you don't know, say you don't know.
         5. Do not offer unprompted advice or clarifications.
         6. Never apologize.
         7. Do NOT summarize your answers.
         </tone>

         <code_generation>
         When generating code:
         1. Always check that functions or variables you use in your code exist.
         2. Also check their calling convention and function-arity before you use them.
         3. Write code that can be tested by evaluation, and offer to evaluate
         code using the `elisp_eval` tool.
         </code_generation>

         <formatting>
         1. When referring to code symbols (variables, functions, tags etc) enclose them in markdown quotes.
            Examples: `read_file`, `getResponse(url, callback)`
            Example: `<details>...</details>`
         2. If you use LaTeX notation, enclose math in \( and \), or \[ and \] delimiters.
         </formatting>"
             :tools '("introspection")
             ${
               if ai.gptel.introspection.model != "" then ":model '${ai.gptel.introspection.model}" else ""
             })
      '';
    };

    gptel-agent = lib.mkIf ai.gptel.agent.enable {
      enable = true;
      config = "(gptel-agent-update)";
      generalOne.global-leader."ga" = lib.mkIf keybinds.leader-key.enable (
        lib.mkDefault '''("agent" . gptel-agent)''
      );
    };
  };
}
