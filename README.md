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
