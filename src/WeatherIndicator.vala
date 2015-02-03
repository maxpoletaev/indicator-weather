using AppIndicator;
using GLib;
using Gtk;

namespace WeatherIndicator {
    class SettingsWindow : Gtk.Window {
        public SettingsWindow() {
            this.title = "Weather Indicator Settings";
            this.set_default_size(100, 100);
        }
    }

    class WeatherIndicator {
        public ulong refresh_interval = 30;

        private Gtk.Window settings_window;
        private YandexProvider provider;
        private Indicator indicator;

        public WeatherIndicator(string city_name) {
            this.provider = new YandexProvider.for_city(city_name);
            this.settings_window = new SettingsWindow();
            this.init_indicator();
            this.init_menu();
            this.init_loop();
        }

        private void init_indicator() {
            this.indicator = new Indicator(
                this.settings_window.title, "indicator-weather",
                IndicatorCategory.APPLICATION_STATUS
            );

            this.indicator.set_status(IndicatorStatus.ACTIVE);
        }

        private void init_menu() {
            var menu = new Gtk.Menu();

            var item_settings = new Gtk.MenuItem.with_label("Settings");
            item_settings.activate.connect(this.action_settings);
            menu.append(item_settings);
            item_settings.show();

            var item_refresh = new Gtk.MenuItem.with_label("Refresh");
            item_settings.activate.connect(this.action_refresh);
            menu.append(item_refresh);
            item_refresh.show();

            var item_close = new Gtk.MenuItem.with_label("Close");
            item_close.activate.connect(this.action_close);
            menu.append(item_close);
            item_close.show();

            this.indicator.set_menu(menu);
        }

        void init_loop() {
            new Thread<void*> ("refresh_loop", () => {
                while(true) {
                    this.refresh();
                    ulong minute = 1000000 * 60;
                    Thread.usleep(minute * this.refresh_interval);
                }
            });
        }

        private void refresh() {
            debug("Refresh");
            var weather = this.provider.now();

            if (weather.loaded) {
                var prefix = (weather.temperature > 0) ? "+" : "";
                this.indicator.label = prefix + weather.temperature.to_string() + "°C";
            }
        }

        private void action_refresh() {
            this.refresh();
        }

        private void action_settings() {
            this.settings_window.show_all();
        }

        private void action_close() {
            Gtk.main_quit();
        }
    }

    static int main(string[] args) {
        Gtk.init(ref args);

        // TODO: Maybe use OptionContext?
        // http://references.valadoc.org/#!api=glib-2.0/GLib.OptionContext

        if (args.length > 1) {
            var indicator = new WeatherIndicator(args[1]);

            if (args.length == 3) {
                indicator.refresh_interval = int.parse(args[2]);
            }
        } else {
            error("Define city name in first argument");
        }

        Gtk.main();
        return 0;
    }
}
