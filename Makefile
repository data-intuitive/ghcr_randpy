randpy:
	docker build -t dataintuitive/randpy:r3.6.3_py3.8.3 .
	docker tag dataintuitive/randpy:r3.6.3_py3.8.3 dataintuitive/randpy:latest

.PHONY: r3.6.3_py3.8.3
r3.6.3_py3.8.3:
	docker build -t dataintuitive/randpy:r3.6.3_py3.6.11 --build-arg PYTHON_VERSION=3.6.11 .

.PHONY: push
push:
	docker push dataintuitive/randpy
