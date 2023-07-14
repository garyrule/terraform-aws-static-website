## Check Input Validation
The module will validate the input variables and set a boolean `z-valid-inputs`.

It will catch some errors that variable validation alone will not catch.

You can check the output of `z-valid-inputs` as part of your plan by checking its status.

```shell
#!/usr/bin/env bash
if [[ $(terraform plan -var-file terraform.tfvars -out tfplan.out -no-color  |grep z-valid-inputs |awk '{print $4}') == "true" ]];then
echo "VALID INPUTS"
else
echo "INVALID INPUTS"
fi
```

or making a one-liner:
```shell
if [[ $(terraform plan -var-file terraform.tfvars -out tfplan.out -no-color  |grep z-valid-inputs |awk '{print $4}') == "true" ]];then echo "VALID INPUTS"; else echo "INVALID INPUTS"; fi
```

Alternatively, you can combine the plan and apply steps based on the output of `z-valid-inputs`:
```shell
if [[ $(terraform plan -var-file terraform.tfvars -out tfplan.out -no-color  |grep z-valid-inputs |awk '{print $4}') == "true" ]];then echo "VALID INPUTS"; terraform apply tfplan.out; else echo "INVALID INPUTS"; fi
```
