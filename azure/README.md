# 🚀 Terraform Platform Overview

---

## 📑 Table of Contents

1. [Introduction](#introduction)
2. [Modules](#modules)
    - [Network Module](#network-module)
    - [VM Module](#vm-module)
    - [Storage Module](#storage-module)
    - [Load Balancer Module](#load-balancer-module)
3. [Compositions](#compositions)
4. [Schemas](#schemas)
5. [Tools](#tools)
6. [Pipelines](#pipelines)
7. [Usage](#usage)

---

## 🏁 Introduction

The Terraform Platform provides a set of reusable modules and compositions for managing AWS infrastructure using Terraform. This project aims to streamline the process of deploying and managing cloud resources, ensuring best practices and modularity.

---

## 🛠️ Modules

### Network Module

The Network module defines resources such as VPCs, subnets, and route tables. It allows for the creation and management of network infrastructure.

### VM Module

The VM module is responsible for defining EC2 instances and EBS volumes. It provides a way to manage virtual machines in the AWS environment.

### Storage Module

The Storage module defines resources for managing S3 buckets and lifecycle rules. It facilitates the storage and retrieval of data in the cloud.

### Load Balancer Module

The Load Balancer module manages resources for Application Load Balancers (ALBs) or Network Load Balancers (NLBs). It ensures high availability and scalability for applications.

---

## 🏗️ Compositions

The compositions directory contains higher-level configurations that orchestrate the use of various modules to create complete application stacks. Each composition can define its own variables and outputs.

---

## 📜 Schemas

The schemas directory contains JSON schemas for validating YAML variable files associated with each module. These schemas ensure that the input variables conform to expected formats and types.

---

## 🛠️ Tools

The tools directory includes utility scripts, such as `yaml2tfvars.py`, which merges multiple YAML files into a single JSON file compatible with Terraform variable files.

---

## 🔄 Pipelines

The pipelines directory contains build specifications for the CI/CD pipeline, defining the steps for validation, planning, applying, and post-validation of Terraform configurations.

---

## 📖 Usage

To use the Terraform Platform, clone the repository and follow the instructions in the respective module and composition README files. Ensure that you have the necessary AWS credentials and permissions to create and manage resources.

--- 

This README serves as a guide to understanding the structure and purpose of the Terraform Platform within the AWS infrastructure as code project.