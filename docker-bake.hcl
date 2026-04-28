target "gcompat" {
  dockerfile = "Dockerfile"
  context    = "."
  args = {
    NODE_VERSION = "25.9.0"
  }
  tags = [
    "ghcr.io/cjntaylor/gcompat:latest"
  ]
  platforms = [
    "linux/arm64",
    "linux/riscv64"
  ]
  output = [
    "type=local,dest=out",
    "type=registry"
  ]
}

group "default" {
  targets = ["gcompat"]
}