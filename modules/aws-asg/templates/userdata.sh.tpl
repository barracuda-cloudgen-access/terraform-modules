#!/bin/bash
%{if cloudwatch_logs_enabled~}

# Install CloudWatch Agent
curl -sL "https://url.access.barracuda.com/config-ec2-cloudwatch-logs" | bash -s -- \
    -l "${aws_cloudwatch_log_group}" \
    -r "${aws_region}"
%{endif~}

# Install CloudGen Access Proxy
curl -sL "https://url.access.barracuda.com/proxy-linux" | bash -s -- \
    -u \
%{if !ssm_parameter_store~}
    -e "DISABLE_AWS_SSM=1" \
%{endif~}
%{if redis_enabled~}
    -r "${redis_primary_endpoint_address}" \
    -s "${redis_port}" \
%{endif~}
    -p "${cloudgen_access_proxy_public_port}" \
    -l "${cloudgen_access_proxy_level}" \
    -e "FYDE_PREFIX=cga_proxy_${random_string_prefix_result}_"

# Harden instance and reboot
curl -sL "https://url.access.barracuda.com/harden-linux" | bash -s --
shutdown -r now
