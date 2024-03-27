{ pkgs, ... }: {
  plugins = {
    # null-ls has been forked to none-ls after the original author archived the project.
    none-ls = {
      enable = true;
      updateInInsert = true;
      enableLspFormat = true;
      sources = {
        code_actions = {
          spellcheck.enable = true; # required?
          gitsigns.enable = true;
          gitrebase.enable = true;
          ts_node_action.enable = true;
          impl.enable = true;
          gomodifytags.enable = true;
          statix.enable = true;
          proselint.enable = true;
          refactoring.enable = true;
        };
        completion = {
          luasnip.enable = true;
          spell.enable = true;
          tags.enable = true;
        };
        diagnostics = {
          actionlint.enable = true;
          ansiblelint.enable = true;
          alex.enable = true;
          buf.enable = true;
          checkmake.enable = true;
          checkstyle.enable = true;
          clazy.enable = true;
          cmake_lint.enable = true;
          codespell.enable = true;
          commitlint.enable = true;
          cppcheck.enable = true;
          deadnix.enable = true;
          dotenv_linter.enable = true;
          editorconfig_checker.enable = true;
          gitlint.enable = true;
          golangci_lint.enable = true;
          hadolint.enable = true;
          ktlint.enable = true;
          ltrs.enable = true;
          markdownlint.enable = true;
          mypy.enable = true;
          protolint.enable = true;
          pylint.enable = true;
          revive.enable = true;
          staticcheck.enable = true;
          statix.enable = true;
          spellcheck.enable = true; # required?
          vale.enable = true;
          write_good.enable = true;
          yamllint.enable = true;
          todo_comments.enable = true;
          trail_space.enable = true;
        };
        formatting = {
          alejandra.enable = true;
          blackd.enable = true;
          isort.enable = true;
          cbfmt.enable = true;
          fnlfmt.enable = true;
          gofmt.enable = true;
          gofumpt.enable = true;
          goimports.enable = true;
          golines.enable = true;
          google_java_format.enable = true;
          leptosfmt.enable = true;
          just.enable = true;
          ktlint.enable = true;
          nixpkgs_fmt.enable = true;
          nixfmt.enable = true;
          markdownlint.enable = true;
          mdformat.enable = true;
          prismaFmt.enable = true;
          prettier.enable = true;
          prettier.disableTsServerFormatter = true;
          protolint.enable = true;
          shellharden.enable = true;
          shfmt.enable = true;
          sqlfluff.enable = true;
          stylua.enable = true;
          typstfmt.enable = true;
          yamlfmt.enable = true;
          # yamlfix.enable = true;
        };
      };
    };
  };
}
