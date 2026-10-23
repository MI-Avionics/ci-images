# ci-images

`ci-base` is the standard job container for MI-Avionics' self-hosted runners (`runs-on: [self-hosted, onprem]`). Those runners require every job to run in a container, so that each job starts clean instead of inheriting whatever earlier jobs left on the host.

Each runner VM builds this Dockerfile itself, at a commit pinned in the Ansible role (`github_runner_ci_base_ref`), and serves it from a registry that only that VM can reach. Jobs refer to it as `localhost:5000/ci-base:1` and need no registry login. The org doesn't allow public packages, so jobs can't pull from ghcr.io without a login. The copy this repo's workflow pushes to `ghcr.io/mi-avionics/ci-base` is private, and isn't what jobs use.

```yaml
jobs:
  build:
    runs-on: [self-hosted, onprem]
    container: localhost:5000/ci-base:1
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - run: terraform version
```

New workflows can start from the org template: **Actions → New workflow → On-prem CI**.

## What's in it

Ubuntu 26.04 (the runner VMs' release, so cached tools work in both) plus:

| Tool | Source |
|---|---|
| git, git-lfs, curl, wget, jq, zip/unzip, rsync, make, build-essential | Ubuntu |
| Python 3 + pip + venv (`python` → `python3`) | Ubuntu; `pip install` works outside a venv (`PIP_BREAK_SYSTEM_PACKAGES=1`) |
| `/bin/sh` is bash; git trusts any directory | So `run:` steps behave as on the host, and root can use the runner's workspace |
| Node.js 24 LTS + npm | NodeSource |
| Terraform 1.17.0 | HashiCorp apt repo (pinned in the Dockerfile) |
| AWS CLI v2 | AWS installer |
| GitHub CLI (`gh`) | GitHub apt repo |
| Salesforce CLI (`sf`) | npm |
| Docker CLI + buildx | Docker apt repo (needs the socket; see below) |

`actions/setup-python`, `actions/setup-node` and `hashicorp/setup-terraform` still work inside it, if a job needs a different version.

## Versions

Jobs use `localhost:5000/ci-base:1`. Each runner VM rebuilds it weekly from the pinned commit, without cache, so OS and tool updates arrive without any change here. A new major (`2`) would only come with a breaking change, such as a new Ubuntu release or a removed tool, so `ci-base:1` users don't break.

## Jobs that need Docker

Job containers have no Docker access. A job that runs `docker build` / `docker run` has to mount the host's socket:

```yaml
    container:
      image: localhost:5000/ci-base:1
      options: -v /var/run/docker.sock:/var/run/docker.sock
```

That gives the job root on the runner VM, so keep it to the jobs that need it.

## Adding a tool

1. Edit the `Dockerfile`, add the tool's version check to the smoke test in `.github/workflows/build.yml`, and open a pull request. The workflow builds and smoke-tests it.
2. Once it's merged, set `github_runner_ci_base_ref` in the Ansible repo's `roles/github_runner/defaults/main.yml` to the new commit and run the runner play (`--tags github_runner`). Each runner VM then rebuilds ci-base before its next job.
