using AppIndicator;
using GLib;
using Gtk;

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

    public WeatherIndicator() {
        this.provider = new YandexProvider.for_city("Тверь");
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
        this.indicator.label = weather.temperature.to_string() + "°C";
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
    new WeatherIndicator();

    Gtk.main();
    return 0;
}
