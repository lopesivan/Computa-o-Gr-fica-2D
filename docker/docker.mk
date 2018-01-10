ls:
	docker images
ps:
	docker ps -a
stop:
	docker ps -aq -f status=running| xargs docker stop
rm:
	docker ps -aq -f status=exited| xargs docker rm
fix:
	docker images -q --filter "dangling=true"| xargs docker rmi -f
