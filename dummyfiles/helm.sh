riables
PROJECT_NAME="my-helm-chart" # Change this to your desired chart name
CHART_DIR="./$PROJECT_NAME" # Directory where the Helm chart will be created

# Ensure the directory does not already exist
if [ -d "$CHART_DIR" ]; then
  echo "Directory $CHART_DIR already exists. Please remove or rename it and try again."
  exit 1
fi

# Create the Helm chart directory structure
mkdir -p "$CHART_DIR/charts"
mkdir -p "$CHART_DIR/templates"
mkdir -p "$CHART_DIR/.helmignore"

# Create Chart.yaml file
cat <<EOF > "$CHART_DIR/Chart.yaml"
apiVersion: v2
name: $PROJECT_NAME
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.0"
EOF

# Create values.yaml file
cat <<EOF > "$CHART_DIR/values.yaml"
# Default values for $PROJECT_NAME.
# This is a YAML-formatted file.
# Declare any variables to be passed into your templates.

replicaCount: 1

image:
  repository: nginx
  tag: "latest"
  pullPolicy: IfNotPresent

service:
  name: default-service
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  name: ""
  path: /
  hosts:
    - host: chart-example.local
      paths: []
  tls: []
EOF

# Create a basic template file (e.g., deployment.yaml)
cat <<EOF > "$CHART_DIR/templates/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: {{ .Release.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: 80
EOF

# Create a basic service template file (e.g., service.yaml)
cat <<EOF > "$CHART_DIR/templates/service.yaml"
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
  selector:
    app: {{ .Release.Name }}
EOF

# Create a .helmignore file
cat <<EOF > "$CHART_DIR/.helmignore"
# Patterns to ignore when packaging.
.git
.github
.gitignore
.DS_Store
*.tgz
*.md
EOF

echo "Helm chart project structure created in $CHART_DIR"

