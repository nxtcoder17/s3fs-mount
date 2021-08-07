Below is an example, that illustrates my usecase of using s3fs spaces as a sidecar to my kubernetes deployment

** Config Map

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: spaces-config
  namespace: com-singlepoint
data:
  BUCKET_NAME: <spaces-bucket-name>
  BUCKET_REGION: <spaces-region-host>
  BUCKET_FOLDER: <spaces-folder-on-which-you-want-to-mount>
```

** Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: spaces-secret
  namespace: com-singlepoint
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: <your-spaces-key>
  AWS_SECRET_ACCESS_KEY: <your-spaces-secret-key>

```


** Deployment

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
        env:
        - name: AWSACCESSKEYID
          valueFrom:
            secretKeyRef:
              key: AWS_ACCESS_KEY_ID
              name: spaces-secret
        - name: AWSSECRETACCESSKEY
          valueFrom:
            secretKeyRef:
              key: AWS_SECRET_ACCESS_KEY
              name: spaces-secret
        - name: BUCKET_NAME
          valueFrom:
            configMapKeyRef:
              key: BUCKET_NAME
              name: spaces-config
        - name: BUCKET_REGION
          valueFrom:
            configMapKeyRef:
              key: BUCKET_REGION
              name: spaces-config
        - name: BUCKET_FOLDER
          valueFrom:
            configMapKeyRef:
              key: BUCKET_FOLDER
              name: spaces-config
        image: nxtcoder17/s3fs-spaces:6
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
