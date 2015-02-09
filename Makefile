all:
	if [ ! -d bin ]; then mkdir bin; fi

	valac --pkg libxml-2.0 --pkg glib-2.0 --pkg gio-2.0 --pkg gtk+-3.0 \
	--pkg appindicator3-0.1 --pkg gee-1.0 --target-glib 2.32 \
	src/Provider.vala src/providers/YandexProvider.vala src/WeatherIndicator.vala \
	-o bin/indicator-weather

clean:
	rm -rf bin
