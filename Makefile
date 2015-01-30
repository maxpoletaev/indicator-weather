all:
	valac --pkg libxml-2.0 --pkg glib-2.0 --pkg gio-2.0 --pkg gtk+-3.0 --pkg appindicator3-0.1 weather-indicator.vala providers.vala

clean:
	rm weather-indicator
