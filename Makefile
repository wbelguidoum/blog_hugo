.DEFAULT_GOAL := deploy

.PHONY: deploy help

m :=

clean_public:
	@echo "🧹 Step 1/5: Cleaning the public directory..."
	rm -fr public

build: clean_public
	@echo "🚀 Step 2/5: Building site with Hugo..."
	hugo

publish: 
ifeq ($(strip $(m)),)
	$(error Commit message is missing. Usage: make deploy m="Your commit message")
endif
	@echo " main repo      | Step 3/5: Adding changes..."
	git add .

	@echo " main repo      | Step 4/5: Committing changes..."
	git commit -m "$(m)"

	@echo " main repo      | Step 5/5: Pushing updates..."
	git push

deploy:
	make build 
	make publish
	@echo "\n✅ All done! Deployment complete."


help:
	@echo 'Usage:'
	@echo '  make deploy m="<your commit message>"    Builds and deploys the site with the given commit message.'
	@echo ''
	@echo 'Example:'
	@echo '  make deploy m="Update blog post about Makefiles"'