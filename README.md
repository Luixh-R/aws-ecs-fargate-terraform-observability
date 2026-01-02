# AWS ECS Fargate – DevOps Observability Project

This project demonstrates how to build a production-grade container
platform on AWS using ECS Fargate, Terraform, GitHub Actions, and
open-source observability tools.

## Core Technologies
- AWS ECS Fargate
- Terraform (Infrastructure as Code)
- GitHub Actions (CI/CD)
- Prometheus (metrics)
- Grafana (dashboards & alerting)
- Loki (centralized logging)

## Goals
- Provision AWS infrastructure using Terraform
- Deploy a containerized application on ECS Fargate
- Implement CI/CD using GitHub Actions
- Collect application metrics using Prometheus
- Visualize metrics and logs in Grafana
- Follow real-world DevOps best practices

## High-Level Architecture
- AWS VPC with public and private subnets
- ECS Fargate services for application and observability stack
- Application Load Balancer for traffic routing
- Prometheus scraping application metrics
- Grafana dashboards and alerts

## Project Status
🚧 Step 1: Project foundation and Terraform setup

## Development Environment

This project is developed and tested using **AWS Playground**,
which provides temporary AWS credentials for hands-on practice.

Due to playground limitations:
- Terraform uses a local backend (state stored locally)
- Managed AWS services (e.g. AMP, AMG) are not used
- Infrastructure is designed to be production-ready but adapted for a sandbox environment

Production-grade alternatives (remote backend, managed observability)
are documented but not enabled.
