# ci-images

`ghcr.io/mi-avionics/ci-base` is the standard job container for MI-Avionics' self-hosted runners (`runs-on: [self-hosted, onprem]`). Those runners require every job to run in a container, so that each job starts clean instead of inheriting whatever earlier jobs left on the host.

```yaml
jobs:
  build:
    runs-on: [self-hosted, onprem]
    container: ghcr.io/mi-avionics/ci-base:1
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - run: terraform version
```

New workflows can start from the org template: **Actions → New workflow → On-prem CI**.

## What's in it

Ubuntu 24.04 plus:

| Tool | Source |
|---|---|
| git, git-lfs, curl, wget, jq, zip/unzip, rsync, make, build-essential | Ubuntu |
| Python 3 + pip + venv (`python` → `python3`) | Ubuntu; `pip install` works outside a venv (`PIP_BREAK_SYSTEM_PACKAGES=1`) |
| Node.js 24 LTS + npm | NodeSource |
| Terraform 1.17.0 | HashiCorp apt repo (pinned in the Dockerfile) |
| AWS CLI v2 | AWS installer |
| GitHub CLI (`gh`) | GitHub apt repo |
| Salesforce CLI (`sf`) | npm |
| Docker CLI + buildx | Docker apt repo (needs the socket; see below) |

`actions/setup-python`, `actions/setup-node` and `hashicorp/setup-terraform` still work inside it, if a job needs a different version.

## Tags

| Tag | Meaning |
|---|---|
| `1` | **Use this.** The current build of major version 1, rebuilt weekly with security updates. |
| `1-YYYYMMDD` | One specific build, if a job must not change. |
| `latest` | Same as the newest major; avoid in workflows. |
| `sha-<commit>` | The build from a given commit of this repo. |

A new major (`2`) only comes with a breaking change, such as a new Ubuntu release or a removed tool, so `ci-base:1` users don't break.

## Jobs that need Docker

Job containers have no Docker access. A job that runs `docker build` / `docker run` has to mount the host's socket:

```yaml
    container:
      image: ghcr.io/mi-avionics/ci-base:1
      options: -v /var/run/docker.sock:/var/run/docker.sock
```

That gives the job root on the runner VM, so keep it to the jobs that need it.

## Adding a tool

Edit the `Dockerfile` and open a pull request. The build workflow builds and smoke-tests it on the PR. Once merged to `main`, it's published as `ci-base:1` within a few minutes. Add the tool's version check to the smoke test in `.github/workflows/build.yml`.
