using Gtk;
using AppIndicator;

public class WeatherIndicator {
    public Indicator indicator;
    public Gtk.Window window;

    public void main() {
        this.window = new Gtk.Window();
        this.window.title = "Weather";
        this.init_indicator();
        this.init_provider();
        this.init_menu();
    }

    private void init_indicator() {
        this.indicator = new Indicator(
            this.window.title, "indicator-weather",
            IndicatorCategory.APPLICATION_STATUS
        );

        this.indicator.set_status(IndicatorStatus.ACTIVE);
    }

    private void init_menu() {
        var menu = new Gtk.Menu();

        var item_close = new Gtk.MenuItem.with_label("Close");
        item_close.activate.connect(this.action_close);
        menu.append(item_close);
        item_close.show();

        this.indicator.set_menu(menu);
    }

    private void init_provider() {
        var provider = new YandexProvider.for_city("Тверь");
        var weather = provider.now();

        this.indicator.label = weather.temperature.to_string() + "°C";
    }

    private void action_close() {
        Gtk.main_quit();
    }
}

static int main(string[] args) {
    Gtk.init(ref args);

    var app = new WeatherIndicator();
    app.main();

    Gtk.main();
    return 0;
}
