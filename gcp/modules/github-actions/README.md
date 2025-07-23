# GitHub Actions GCP WIF Provider Module

This module helps you setup GCP Workload Identity Federation (WIF) with GitHub Actions.

Minimum configuration To use the module, the following needs to be specified:

```
module "gh_actions" {
    source = "github.com/rickliujh/tf-tmpl//gcp/modules/github-actions"

    project_id    = "go-kickstart"
    github_org    = "rickliujh"
    github_repo   = "kickstart-gogrpc"
    github_org_id = "36358701"
}
```


