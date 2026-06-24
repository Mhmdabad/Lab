# Reusable GitHub Actions Workflows

Reusable workflows allow you to define a single workflow (e.g., building and publishing Docker images) and share it across multiple other workflows or repositories, reducing duplication and easing maintenance.

---

## 1. The Reusable Workflow (`workflow_call`)

The [buildAndPublishDockerImage.yml](file:///c:/Users/97253/Desktop/Lab/ci%20cd/Reusable%20Workflows/.github/workflows/buildAndPublishDockerImage.yml) file is configured as reusable by declaring `on: workflow_call`.

### Inputs and Secrets Configuration:
- **Inputs** (passed using `with:`):
  - `image_name` (String, Required): The name of the Docker image to build.
  - `image_tag` (String, Optional, defaults to `latest`): The tag to apply to the built image.
- **Secrets** (passed using `secrets:`):
  - `DOCKER_USERNAME` (Required): Docker registry username.
  - `DOCKER_PASSWORD` (Required): Docker registry password.

---

## 2. Calling the Reusable Workflow

To call a reusable workflow, use the `uses` keyword in your job definition and supply the required parameters.

**Example from [caller.yml](file:///c:/Users/97253/Desktop/Lab/ci%20cd/Reusable%20Workflows/.github/workflows/caller.yml):**

```yaml
jobs:
  call-reusable-workflow:
    uses: ./.github/workflows/buildAndPublishDockerImage.yml
    with:
      image_name: 'my-app'
      image_tag: '1.0.0'
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

---

## 3. Benefits of Reusable Workflows
- **Dry (Don't Repeat Yourself)**: Write the build and push logic once and reuse it across multiple projects.
- **Centralized Updates**: If you need to update the Docker action versions or add scanning, you only update the reusable workflow.
