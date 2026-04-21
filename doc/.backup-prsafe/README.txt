Rollback (restore files touched by pr-safe edits):

  Copy the newest *.yyyyMMdd-HHmmss files here over the originals under doc/, e.g.:

  supplemental-ui/partials/footer-scripts.hbs
  modules/ROOT/pages/preface.adoc
  modules/ROOT/pages/acknowledgements.adoc
  supplemental-ui/css/accumulators-dlist.css

Or use git checkout -- <path> if these paths are not yet committed.

Note: build/site (adoc-html) is not copied here; regenerate with:
  cd doc && npx antora local-playbook.yml
(and append accumulators-dlist to site.css per build_antora.sh if you use that step).
