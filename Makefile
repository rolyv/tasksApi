zip-lambdas: lambda_functions/*.py
	zip -rj lambda_funcs.zip lambda_functions/*.py

clean-zip:
	rm -f lambda_funcs.zip

clean-deploy:
	terraform destory -force

clean-all:
	clean-zip
	clean-deploy

deploy: zip-lambdas
	terraform apply
