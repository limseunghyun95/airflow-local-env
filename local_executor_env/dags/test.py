from __future__ import annotations
from datetime import datetime, timedelta
from airflow.decorators import dag, task


@dag(
    dag_id="temp_hello_dag_v310_taskflow",
    description="Temporary DAG using TaskFlow API (Airflow 3.1.0)",
    start_date=datetime(2025, 1, 1),
    schedule_interval="@daily",
    catchup=False,
    default_args={
        "owner": "airflow",
        "depends_on_past": False,
        "email_on_failure": False,
        "email_on_retry": False,
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
    },
    tags=["temp", "test", "taskflow", "v3.1.0"],
)
def temp_hello_dag():
    """A simple TaskFlow DAG example for Airflow 3.1.0."""

    @task
    def print_hello() -> str:
        msg = "Hello from Airflow 3.1.0 TaskFlow DAG!"
        print(msg)
        return msg

    @task
    def print_world(previous_msg: str) -> None:
        print(previous_msg + " 👋 World!")

    msg = print_hello()
    print_world(msg)


# Instantiate the DAG
temp_hello_dag()

