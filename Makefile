init: docker-down-clear docker-pull docker-build docker-up
up: docker-up
down: docker-down

docker-up:
	docker compose up -d

docker-down:
	docker compose down --remove-orphans

docker-down-clear:
	docker compose down -v --remove-orphans

docker-pull:
	docker compose pull

docker-build:
	docker compose build

deploy:
	ssh deploy@${HOST} 'rm -rf registry && mkdir registry'
	scp docker-compose-production.yml deploy@${HOST}:registry/docker-compose.yml
	scp -r docker deploy@${HOST}:registry/docker
	scp ${HTPASSWD_FILE} deploy@${HOST}:registry/htpasswd
	ssh deploy@${HOST} 'cd registry && docker compose down --remove-orphans'
	ssh deploy@${HOST} 'cd registry && docker compose pull'
	ssh deploy@${HOST} 'cd registry && docker compose up -d'

remove-old-images:
	ssh deploy@${HOST} 'cd registry && docker compose run --rm registry-cli -l "${USER}":"${PASS}" -r http://registry:5000 --delete --num 1'
	ssh deploy@${HOST} 'cd registry && docker compose stop registry'
	ssh deploy@${HOST} 'cd registry && docker compose run --rm registry bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml'
	ssh deploy@${HOST} 'cd registry && docker compose up -d registry'
