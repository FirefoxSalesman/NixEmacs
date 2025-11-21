{
  config,
  lib,
  ...
}:

{
  options.programs.emacs.init.ide.project =
    lib.mkEnableOption "Enables project.el for project management. Projection is used to provide quick build options";

  config.programs.emacs.init.usePackage = lib.mkIf config.programs.emacs.init.ide.project {
    project = {
      enable = true;
      setopt.project-vc-extra-root-markers = [
        ''"Cargo.toml"''
        ''"?*.cabal"''
        ''"build.gradle"''
        ''"?*.csproj"''
        ''"?*.fsproj"''
        ''"?*.sln"''
        ''"?*.nimble"''
        ''"go.work"''
        ''"go.mod"''
        ''"*.go"''
        ''"Taskfile.yml"''
        ''"SConstruct"''
        ''"meson.build"''
        ''"flake.nix"''
        ''"WORKSPACE"''
        ''"configure.ac"''
        ''"configure.in"''
        ''"CMakeLists.txt"''
        ''"composer.json"''
        ''"rebar.config"''
        ''"mix.exs"''
        ''"Gruntfile.js"''
        ''"gulpfile.js"''
        ''"yarn.lock"''
        ''"pnpm-lock.yaml"''
        ''"package.json"''
        ''"angular.json"''
        ''"manage.py"''
        ''"requirements.txt"''
        ''"setup.py"''
        ''"pyproject.toml"''
        ''"tox.ini"''
        ''"Pipfile"''
        ''"poetry.lock"''
        ''"pom.xml"''
        ''"build.gradle.kts"''
        ''"application.yml"''
        ''"build.sbt"''
        ''"build.sc"''
        ''"project.clj"''
        ''"build.boot"''
        ''"deps.edn"''
        ''".bloop"''
        ''"Gemfile"''
        ''"shard.yml"''
        ''"Cask"''
        ''"Eask"''
        ''"Eldev"''
        ''"DESCRIPTION"''
        ''"stack.yaml"''
        ''"info.rkt"''
        ''"pubspec.yaml"''
        ''"elm.json"''
        ''"Project.toml"''
        ''"dune-project"''
      ];
      generalOne.global-leader."P" = lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable (
        lib.mkDefault "project-prefix-map"
      );
    };

    projection-multi = {
      enable = true;
      bindLocal.project-prefix-map."RET" = "projection-multi-compile";
      config = ''
        (require 'projection)
        (global-projection-hook-mode)
        (oset projection-project-type-maven build "mvn -B clean compile")
      '';
    };

    projection-multi-embark = lib.mkIf config.programs.emacs.init.completions.smallExtras.embark {
      enable = true;
      after = [
        "embark"
        "projection-multi"
      ];
      config = "(projection-multi-embark-setup-command-map)";
    };
  };
}
