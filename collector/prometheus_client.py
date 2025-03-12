import requests

class PrometheusClient:
    def __init__(self, prometheus_url="http://localhost:9090"):
        self.prometheus_url= prometheus_url

    def query(self, prom_query):
        print(f"Running query: {prom_query}")
        #Send query
        response = requests.get(f"{self.prometheus_url}/api/v1/query", params={"query": prom_query})
        #Print response code and text if failed
        if response.status_code!=200:
            raise Exception(f"Prometheus query failed: {response.status_code} {response.text}")
        return response.json()['data']['result']
    
    def get_cpu_usage(self, namespace='default'):
        query = f'rate(container_cpu_usage_seconds_total{{namespace="{namespace}"}}[5m])'
        return self.query(query)
    
    def get_memory_usage(self, namespace="default"):
        query = f'container_memory_usage_bytes{{namespace="{namespace}"}}'
        return self.query(query)