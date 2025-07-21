push:
	git add .
	git commit -a -m="${m}"
	git push

gt:
	flutter pub get

gen:
	dart run build_runner watch -d