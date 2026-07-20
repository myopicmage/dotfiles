build:
	darwin-rebuild build --flake .#m2
switch:
	sudo darwin-rebuild switch --flake .#m2
