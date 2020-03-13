# App for Tekton CD

XXX https://tekton.dev/

XXX based on 0.10.1

XXX download CLI

```bash
curl -s https://api.github.com/repos/tektoncd/cli/releases/latest | \
    jq --raw-output '.assets[] | select(.name | endswith("_Linux_x86_64.tar.gz")) | .browser_download_url' | \
    xargs curl -sLf | tar -xvzC /usr/local/bin/ tkn
```

## Example

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: echo-hello-world
spec:
  steps:
    - name: echo
      image: ubuntu
      command:
        - echo
      args:
        - "Hello World"
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: echo-hello-world-task-run
spec:
  taskRef:
    name: echo-hello-world
```
