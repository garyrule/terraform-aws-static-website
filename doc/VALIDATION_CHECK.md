## Check Input Validation
The module will validate the input variables and set a local boolean `z_valid_inputs`.

It will catch some errors that variable validation alone will not catch, such as setting `dns_type`
to `gandi` and not providing the `gandi_key`.

You can check the output of `z_valid_inputs` as part of your plan by checking its value at plan time.

```shell
#!/usr/bin/env bash
if [[ $(terraform plan -var-file terraform.tfvars -out tfplan.out -no-color  |grep z_valid_inputs |awk '{print $4}') == "true" ]];then
    echo "VALID INPUTS"
else
    echo "INVALID INPUTS"
fi
```

### Conditional Application

#### Sentinel
If you use a policy enforcement tool like [Sentinel](https://docs.hashicorp.com/sentinel/terraform), you can fail the plan based on the value.

#### One-liner to conditionally apply the plan
```shell
if [[ $(terraform plan -var-file terraform.tfvars -out tfplan.out -no-color  |grep z_valid_inputs |awk '{print $4}') == "true" ]];then echo "VALID INPUTS"; terraform apply tfplan.out; else echo "INVALID INPUTS"; fi
```
