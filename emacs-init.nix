{ config, lib, inputs, pkgs, ... }:

with lib;

let

  cfg = config.programs.emacs.init;

  packageFunctionType = mkOptionType {
    name = "packageFunction";
    description = "function from epkgs to package";
    check = isFunction;
    merge = mergeOneOption;
  };

  usePackageType = types.submodule ({ name, config, ... }: {
    options = {
      enable = mkEnableOption "Emacs package ${name}";
    
      package = mkOption {
        type = types.either (types.str // { description = "name of package"; })
          packageFunctionType;
        default = name;
        description = ''
          The package to use for this module. Either the package name
          within the Emacs package set or a function taking the Emacs
          package set and returning a package.
        '';
      };
    
      chords = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          "jj" = "ace-jump-char-mode";
          "jk" = "ace-jump-word-mode";
        };
        description = ''
          The entries to use for <option>:chords</option>.
        '';
      };
      
      bind = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          "M-<up>" = "drag-stuff-up";
          "M-<down>" = "drag-stuff-down";
        };
        description = ''
          The entries to use for <option>:bind</option>.
        '';
      };
      
      general = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          "[remap describe-variable]" = "helpful-variable";
        };
        description = ''
          The entries to use for global keys in <option>:general</option>.
          The function does not quote your bindings for you, with the intention of being able to use it for remaps.
        '';
      };
      
      generalOne = mkOption {
        type = types.attrsOf (types.attrsOf types.str);
        default = { };
        example = {
          "'normal" = { "/" = "consult-line"; };
        };
        description = ''
          The entries to use for keymaps with 1 argument in <option>:general</option>.
        '';
      };
      
      generalTwo = mkOption {
        type = types.attrsOf (types.attrsOf (types.attrsOf types.str));
        default = { };
        example = {
          "'normal".vundo-mode-map."C-e" = "'vundo-next";
        };
        description = ''
          The entries to use for keymaps with 2 arguments in <option>:general</option>.
        '';
      };
      
      bindLocal = mkOption {
        type = types.attrsOf (types.attrsOf types.str);
        default = { };
        example = {
          helm-command-map = { "C-c h" = "helm-execute-persistent-action"; };
        };
        description = ''
          The entries to use for local keymaps in <option>:bind</option>.
        '';
      };
      
      bindKeyMap = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = { "C-c p" = "projectile-command-map"; };
        description = ''
          The entries to use for <option>:bind-keymap</option>.
        '';
      };
    
      mode = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:mode</option>.
        '';
      };
      
      after = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:after</option>.
        '';
      };
      
      afterCall = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:after-call</option>.
        '';
      };
      
      defer = mkOption {
        type = types.either types.bool types.ints.positive;
        default = false;
        description = ''
          The <option>:defer</option> setting.
        '';
      };
      
      deferIncrementally = mkOption {
        type = types.either types.bool (types.listOf types.str);
        default = false;
        description = ''
          The <option>:defer-incrementally</option> setting.
        '';
      };
      
      command = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:commands</option>.
        '';
      };
      
      
      hook = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:hook</option>.
        '';
      };
      
      ghook = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:ghook</option>.
        '';
      };
      
      gfhook = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:gfhook</option>.
        '';
      };
    
      defines = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:defines</option>.
        '';
      };
    
      eglot = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Starts eglot upon loading the major mode.
        '';
      };
      
      symex = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If this is true, pressing enter in the package's mode map will start symex
        '';
      };
    
      demand = mkOption {
        type = types.bool;
        default = false;
        description = ''
          The <option>:demand</option> setting.
        '';
      };
    
      diminish = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:diminish</option>.
        '';
      };
    
      functions = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The entries to use for <option>:functions</option>.
        '';
      };
    
      custom = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          "display-line-numbers-type" = "'relative";
        };
        description = ''
          The entries to use for <option>:custom</option>.
        '';
      };
    
      config = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Code to place in the <option>:config</option> section.
        '';
      };
    
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Additional lines to place in the use-package configuration.
        '';
      };
    
      earlyInit = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Lines to add to <option>programs.emacs.init.earlyInit</option> when
          this package is enabled.
          </para><para>
          Note, the package is not automatically loaded so you will have to
          <literal>require</literal> the necessary features yourself.
        '';
      };
    
      init = mkOption {
        type = types.lines;
        default = "";
        description = ''
          The entries to use for <option>:init</option>.
        '';
      };
    
      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = ''
          Extra packages to add to <option>home.packages</option>.
        '';
      };
    
      assembly = mkOption {
        type = types.lines;
        readOnly = true;
        internal = true;
        description = "The final use-package code.";
      };
    };
  
    config = mkIf config.enable {
      assembly = let
        quoted = v: ''"${escape [ ''"'' ] v}"'';
        mkBindHelper = cmd: prefix: bs:
          optionals (bs != { }) ([ ":${cmd} (${prefix}" ]
                                 ++ mapAttrsToList (n: v: "  (${quoted n} . ${v})") bs ++ [ ")" ]);
        mkGeneralHelper = mode: map: bs:
          optionals (bs != { }) ([ "(${mode} ${map}" ]
                                 ++ mapAttrsToList (n: v: "  ${quoted n} ${v}") bs ++ [")"]);
        mkGeneralLocalHelper = state: bs:
          let mkMap = n: v: mkGeneralHelper "${state}" "${n}" v;
          in flatten (mapAttrsToList mkMap bs);
        mkAfter = vs: optional (vs != [ ]) ":after (${toString vs})";
        mkAfterCall = vs: optional (vs != [ ]) ":after-call (${toString vs})";
        mkCommand = vs: optional (vs != [ ]) ":commands (${toString vs})";
        # Having :custom before every statement grants better load times. No idea why
        mkCustom = vs: optionals (vs != { }) (mapAttrsToList (n: v: ":custom (${n} ${v})") vs);
        mkDefines = vs: optional (vs != [ ]) ":defines (${toString vs})";
        mkDiminish = vs: optional (vs != [ ]) ":diminish (${toString vs})";
        mkMode = vs: optional (vs != [ ]) ":mode ${toString vs}";
        mkFunctions = vs: optional (vs != [ ]) ":functions (${toString vs})";
        mkBind = mkBindHelper "bind" "";
        mkGeneral = bs:
          optionals (bs != { }) (["("] ++ mapAttrsToList (n: v: ''  "${n}" ${v}'') bs ++ [")"]);
        mkGeneralOne = bs:
          let mkMap = n: v: mkGeneralHelper "${n}" "" v;
          in flatten (mapAttrsToList mkMap bs);
        mkGeneralTwo = bs:
          let mkMap = n: v: mkGeneralLocalHelper "${n}" v;
          in flatten (mapAttrsToList mkMap bs);
        buildGeneral = zero: one: two: optionals (zero != {} || one != {} || two != {}) [":general"] ++ mkGeneral zero ++ mkGeneralOne one ++ mkGeneralTwo two;
        mkBindLocal = bs:
          let mkMap = n: v: mkBindHelper "bind" ":map ${n}" v;
          in flatten (mapAttrsToList mkMap bs);
        mkBindKeyMap = mkBindHelper "bind-keymap" "";
        mkChords = mkBindHelper "chords" "";
        mkHook = vs: optional (vs != [ ]) ":hook ${toString vs}";
        mkGhook = vs: optional (vs != [ ]) ":ghook ${toString vs}";
        mkGfhook = vs: optional (vs != [ ]) ":gfhook ${toString vs}";
        transformName = name: let matches = p: n: match p n != null;
                              in if matches "tex-mode" name then "latex-mode" else if matches "latex" name then "LaTeX-mode" else if matches ".*-mode" name then name else "${name}-mode";
        mkEglot = name: vs: optional vs [''(${transformName name} . (lambda () (require 'eglot) (eglot-ensure)))''];
        mkSymex = name: vs: optional vs '':general ('normal ${transformName name}-map "RET" '(lambda () (interactive) (require 'symex) (symex-mode-interface)))'';
        mkDefer = v:
          if isBool v then
            optional v ":defer t"
          else
            [ ":defer ${toString v}" ];
        mkDeferIncrementally = v:
          if isBool v then
            optional v ":defer-incrementally t"
          else
            map (n: ":defer-incrementally ${n}") v;
        mkDemand = v: optional v ":demand t";
      in concatStringsSep "\n  " ([ "(use-package ${name}" ]
                                  ++ mkAfter config.after ++ mkAfterCall config.afterCall ++ mkBind config.bind
                                  ++ mkBindKeyMap config.bindKeyMap ++ mkBindLocal config.bindLocal
                                  ++ mkChords config.chords ++ mkCommand config.command
                                  ++ mkDefer config.defer ++ mkDeferIncrementally config.deferIncrementally 
                                  ++ mkDefines config.defines
                                  ++ mkFunctions config.functions ++ mkDemand config.demand
                                  ++ mkDiminish config.diminish ++ mkHook (config.hook ++ mkEglot name config.eglot)
                                  ++ mkGhook config.ghook
                                  ++ mkGfhook config.gfhook ++ mkCustom config.custom
                                  ++ buildGeneral config.general config.generalOne config.generalTwo ++ mkSymex name config.symex
                                  ++ mkMode config.mode
                                  ++ optionals (config.init != "") [ ":init" config.init ]
                                  ++ optionals (config.config != "") [ ":config" config.config ]
                                  ++ optional (config.extraConfig != "") config.extraConfig) + ")";
    };
  });
  usePackageStr = name: pkgConfStr: ''
    (use-package ${name}
      ${pkgConfStr})'';
  
  mkRecommendedOption = type: extraDescription:
    mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Whether to enable recommended ${type} settings.
      '' + optionalString (extraDescription != "") ''
        </para><para>
        ${extraDescription}
      '';
    };
  
  # Recommended GC settings.
  gcSettings = ''
    (defun hm/reduce-gc ()
      "Reduce the frequency of garbage collection."
      (setq gc-cons-threshold most-positive-fixnum
            gc-cons-percentage 0.6))
  
    (defun hm/restore-gc ()
      "Restore the frequency of garbage collection."
      (setq gc-cons-threshold 16777216
            gc-cons-percentage 0.1))
  
    ;; Make GC more rare during init, while minibuffer is active, and
    ;; when shutting down. In the latter two cases we try doing the
    ;; reduction early in the hook.
    (hm/reduce-gc)
    (add-hook 'minibuffer-setup-hook #'hm/reduce-gc -50)
    (add-hook 'kill-emacs-hook #'hm/reduce-gc -50)
  
    ;; But make it more regular after startup and after closing minibuffer.
    (add-hook 'emacs-startup-hook #'hm/restore-gc)
    (add-hook 'minibuffer-exit-hook #'hm/restore-gc)
  
    ;; Avoid unnecessary regexp matching while loading .el files.
    (defvar hm/file-name-handler-alist file-name-handler-alist)
    (setq file-name-handler-alist nil)
  
    (defun hm/restore-file-name-handler-alist ()
      "Restores the file-name-handler-alist variable."
      (setq file-name-handler-alist hm/file-name-handler-alist)
      (makunbound 'hm/file-name-handler-alist))
    
    (add-hook 'emacs-startup-hook #'hm/restore-file-name-handler-alist)
  '';
  
  # Whether the configuration makes use of `:diminish`.
  hasDiminish = any (p: p.diminish != [ ]) (attrValues cfg.usePackage);
  
  # Whether the configuration makes use of `:defer-incrementally`.
  hasDoom = any (p: (p.deferIncrementally != [ ] && p.deferIncrementally != false) || p.afterCall != [ ] || cfg.largeFileHandling) (attrValues cfg.usePackage);
  
  # Whether the configuration makes any use of general keywords.
  hasGeneral = any (p: p.symex != false || p.ghook != [ ] || p.gfhook != [ ] || p.generalOne != { } || p.generalTwo != { } || p.general != { }) (attrValues cfg.usePackage);
  
  hasSymex = any (p: p.symex != false) (attrValues cfg.usePackage);
  
  # Whether the configuration makes use of `:bind`.
  hasBind = any (p: p.bind != { } || p.bindLocal != { } || p.bindKeyMap != { })
    (attrValues cfg.usePackage);
  
  # Whether the configuration makes use of `:chords`.
  hasChords = any (p: p.chords != { }) (attrValues cfg.usePackage);
  usePackageSetup = ''
    (require 'use-package)
    ;; To help fixing issues during startup.
    (setq use-package-verbose ${
      if cfg.usePackageVerbose then "t" else "nil"
    })
  '' + ''
  ;; Optimizes for large file handling
    ${if cfg.largeFileHandling then
      "(use-package doom-large-file
      :demand t)"
      else ""
     }
    '' + optionalString hasDiminish ''
  ;; For :diminish in (use-package).
    (require 'diminish)
    '' + optionalString hasDoom ''
  ;; For :defer-incrementally in (use-package).
    (use-package doom-defer
     :demand t)
    '' + optionalString hasGeneral ''
  ;; For any general keywords in (use-package).
    (use-package general
     :demand t
     :config
       (general-auto-unbind-keys))
    '' + optionalString hasBind ''
  ;; For :bind in (use-package).
    (require 'bind-key)
  
  ;; Fixes "Symbol’s function definition is void: use-package-autoload-keymap".
    (autoload #'use-package-autoload-keymap "use-package-bind-key")
      '' + optionalString hasChords ''
     ;; For :chords in (use-package).
       (use-package use-package-chords
        :config (key-chord-mode 1))
  '';
  earlyInitFile = ''
    ;;; hm-early-init.el --- Emacs configuration à la Home Manager -*- lexical-binding: t; -*-
    ;;
    ;;; Commentary:
    ;;
    ;; The early init component of the Home Manager Emacs configuration.
    ;;
    ;;; Code:
  
    ;; Avoid expensive frame resizing. Inspired by Doom Emacs.
    (setq frame-inhibit-implied-resize t)
  
    ${optionalString cfg.recommendedGcSettings gcSettings}
  
    ${cfg.earlyInit}
    (provide 'hm-early-init)
    ;; hm-early-init.el ends here
  '';
in {
  options.programs.emacs.init = {
    enable = mkEnableOption "Emacs configuration";
  
    recommendedGcSettings = mkRecommendedOption "garbage collection" ''
      This will reduce garbage collection frequency during startup and
      while the minibuffer is active.
    '';
  
    # Credits: The large file handling package is from Noctuid
    largeFileHandling = mkEnableOption "Optimizes operations on large text files";
  
    startupTimer = mkEnableOption "Emacs startup duration timer";
  
    earlyInit = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Configuration lines to add in <filename>early-init.el</filename>.
      '';
    };
  
    prelude = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Configuration lines to add in the beginning of
        <filename>init.el</filename>.
      '';
    };
  
    postlude = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Configuration lines to add in the end of
        <filename>init.el</filename>.
      '';
    };
  
    packageQuickstart = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable package-quickstart. This will make sure that
        <literal>package.el</literal> is activated and all autoloads are
        available.
        </para><para>
        If disabled you can save quite a few milliseconds on the startup time,
        but you will most likely have to tweak the <literal>command</literal>
        option of various packages.
        </para><para>
        As an example, running <literal>(emacs-init-time)</literal> on an Emacs
        configuration with this option enabled reported ~300ms. Disabling the
        option dropped the init time to ~200ms.
      '';
    };
  
    usePackageVerbose = mkEnableOption "verbose use-package mode";
  
    usePackage = mkOption {
      type = types.attrsOf usePackageType;
      default = { };
      example = literalExpression ''
        {
          dhall-mode = {
            mode = [ '''"\\.dhall\\'"''' ];
          };
        }
      '';
      description = ''
        Attribute set of use-package configurations.
      '';
    };
  };
  
  config = mkIf (config.programs.emacs.enable && cfg.enable) {
    programs.emacs.extraPackages = epkgs:
      let
        getPkg = v:
          if isFunction v then
            [ (v epkgs) ]
          else
            optional (isString v && hasAttr v epkgs) epkgs.${v};
  
        packages = concatMap (v: getPkg (v.package))
          (filter (getAttr "enable") (builtins.attrValues cfg.usePackage));
      in [
        epkgs.use-package
        (epkgs.trivialBuild {
          pname = "hm-early-init";
          src = pkgs.writeText "hm-early-init.el" earlyInitFile;
          version = "0.1.0";
          packageRequires = packages;
          preferLocalBuild = true;
          allowSubstitutes = false;
        })
      ] ++ optionals hasGeneral [epkgs.general]
      ++ optionals hasDoom [
        (epkgs.callPackage ./emacs-packages/doom-utils.nix {
          inherit inputs;
          inherit (epkgs) trivialBuild;
        })
      ] ++
      optionals hasSymex [
        (epkgs.callPackage ./emacs-packages/symex2.nix {
          inherit inputs;
          inherit (epkgs) trivialBuild tsc tree-sitter paredit evil evil-surround seq;
        })
      ] ++ packages ;
  
    # Collect the extra packages that should be included in the user profile.
    # These are typically tools called by Emacs packages.
    home.packages = concatMap (v: v.extraPackages)
      (filter (getAttr "enable") (builtins.attrValues cfg.usePackage));
  
    home.file = {
      ".config/emacs/early-init.el".text = ''
        (require 'hm-early-init)
      '';
  
      ".config/emacs/init.el".text = ''
        ${if cfg.packageQuickstart then ''
          (setq package-quickstart t
                package-quickstart-file "hm-package-quickstart.el")
        '' else ''
          (setq package-enable-at-startup nil)
        ''}
  
  
      ${usePackageSetup}
      ${cfg.prelude}
      '' + concatStringsSep "\n\n" (map (getAttr "assembly")
        (filter (getAttr "enable") (attrValues cfg.usePackage))) + ''
  
        ${cfg.postlude}
      '';
    };
  };
}
