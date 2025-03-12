from prometheus_client import PrometheusClient

PROMETHEUS_URL = "http://localhost:9090"

def main():
    prom = PrometheusClient(PROMETHEUS_URL)

    cpu_data = prom.get_cpu_usage(namespace="application")
    print(cpu_data)
    memory_data = prom.get_memory_usage(namespace="application")
    print(memory_data)
if __name__ == "__main__":
    main()