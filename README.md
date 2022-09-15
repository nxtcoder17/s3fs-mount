Below is an example, that illustrates my usecase of using s3fs spaces as a sidecar to my kubernetes deployment

## Usage

| key                   | value                                                                                                                         |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| AWS_ACCESS_KEY_ID     |                                                                                                                               |
| AWS_SECRET_ACCESS_KEY |                                                                                                                               |
| BUCKET_NAME           | name of the s3 compatible bucket                                                                                              |
| BUCKET_DIR            | subpath of s3 bucket which you would like to mount, defaults to /                                                             |
| BUCKET_URL            | must be something of form `https://{{region}}.{{domain}}`, don't include bucket name in the url, s3fs does not like it        |
| MOUNT_DIR             | host file system dir path , where you want the s3 storage mount to be mounted                                                 |
| PASSWORD_FILE         | this file is output of  `echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY`, it is calculated automatically by this docker image |

```bash
s3fs $BUCKET_NAME:/$BUCKET_DIR $MOUNT_DIR -o url=https://$BUCKET_URL -o allow_other -o use_path_request_style -o passwd_file=$PASSWORD_FILE
```

**ConfigMap**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: s3-config
  namespace: sample-namespace
data:
  BUCKET_NAME: example-bucket # your bucket name
  BUCKET_URL: https://sgp1.digitaloceanspaces.com # your bucket url in the same format
  BUCKET_DIR: /images  # mount example-bucket/images
```

**Secret**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: s3-secret
  namespace: sample-namespace
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: <your-spaces-key>
  AWS_SECRET_ACCESS_KEY: <your-spaces-secret-key>
```

**Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: sample-namespace
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: sample-namespace
  template:
    metadata:
      labels:
				app: sample-namespace
    spec:
      containers:
      - args:
        - -c
        - './run.sh && echo running... && trap : TERM INT; (while true; do sleep 10;
          done) && wait'
        command:
        - /bin/sh
        envFrom:
          - secretRef:
              name: s3-secret
          - configMapRef:
              name: s3-config
        image: nxtcoder17/s3fs-spaces:7
        imagePullPolicy: Always
        name: spaces-sidecar
        resources:
          requests:
            cpu: 150m
            memory: 150Mi
          limits:
            cpu: 200m
            memory: 200Mi
        securityContext:
          capabilities:
            add:
            - SYS_ADMIN
          privileged: true
        volumeMounts:
        - mountPath: /data
          mountPropagation: Bidirectional
          name: shared-data

      - image: <your-app-docker-image>
        imagePullPolicy: IfNotPresent
        name: singlepoint-api
        env:
          - name: SPACES_DIRECTORY
            value: /spaces/sample
        resources:
          requests:
            cpu: 150m
            memory: 150Mi
          limits:
            cpu: 200m
            memory: 200Mi
        volumeMounts:
        - mountPath: /spaces
          mountPropagation: HostToContainer
          name: shared-data
      volumes:
      - emptyDir: {}
        name: shared-data
```
