randpy:
	docker build -t dataintuitive/randpy:r3.6.3_py3.8.3 -f r3.6.3_py3.8.3/Dockerfile .
	docker tag dataintuitive/randpy:r3.6.3_py3.8.3 dataintuitive/randpy:latest

.PHONY: push
push:
	docker push dataintuitive/randpy
