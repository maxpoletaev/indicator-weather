using Xml.XPath;
using GLib;
using Xml;
using Gee;

namespace WeatherIndicator {
    struct Weather {
        string weather_type;
        int temperature;
        string image;
        string url;
    }

    interface Provider {
        public abstract Weather now();
    }

    class YandexProvider : Provider {
        private HashMap<string, int> city_list;
        public string city_name;
        public int city_id;

        public YandexProvider.for_city(string city_name) {
            this.city_list = this.get_city_list();
            this.city_id = this.get_city_id(city_name);
            this.city_name = city_name;
        }

        public Weather now() {
            var data = this.get_weather_data();

            Xml.Doc* doc = Xml.Parser.read_memory(data, data.length);
            Xml.Node* root = doc->get_root_element();

            if (root == null) {
                // TODO: Error handling
            }

            var fact_node = this.get_node_by_name(root, "fact");

            var weather = Weather() {
                temperature = int.parse(this.get_node_by_name(fact_node, "temperature")->get_content()),
                weather_type = this.get_node_by_name(fact_node, "weather_type")->get_content()
            };

            delete doc;
            return weather;
        }

        private string get_weather_data() {
            var file = File.new_for_uri(@"http://export.yandex.ru/weather-ng/forecasts/$(this.city_id).xml");
            var result = "";

            try {
                if (file.query_exists()) {
                    var stream = new DataInputStream(file.read());
                    string line;

                    while ((line = stream.read_line(null)) != null) {
                        result += line;
                    }
                }
            } catch (GLib.Error e) {
                stdout.printf("Error: %s \n", e.message);
            }

            return result;
        }

        private int get_city_id(string city_name) {
            if (city_name in this.city_list) {
                return this.city_list[city_name];
            }

            error("City does not exists");
        }

        private HashMap<string, int> get_city_list() {
            Xml.Doc* doc = Xml.Parser.parse_file("data/yandex_cities.xml");
            Xml.Node* root = doc->get_root_element();
            var map = new HashMap<string, int>();

            for (Xml.Node* country = root->children; country != null; country = country->next) {
                if (country->name == "country") {
                    for (Xml.Node* city = country->children; city != null; city = city->next) {
                        if (city->name == "city") {
                            map[city->get_content()] = int.parse(city->get_prop("id"));
                        }
                    }
                }
            }

            delete doc;
            return map;
        }

        private Xml.Node* get_node_by_name(Xml.Node* node, string node_name) {
            for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == node_name) {
                    return iter;
                }
            }

            return null;
        }
    }
}
