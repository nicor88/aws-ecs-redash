PROFILE=nicor88

init:
	terraform_latest get && terraform_latest init

plan:
	cd infrastructure && AWS_PROFILE=$(PROFILE) terraform_latest plan

apply: plan
	cd infrastructure && AWS_PROFILE=$(PROFILE) terraform_latest apply -auto-approve

redash-up: redash-down
	docker-compose up

redash-down:
	docker-compose down

clean-pg:
	rm -rf postgres_data