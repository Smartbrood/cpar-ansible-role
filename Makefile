.PHONY: run ansible_config host_syntax_check host_test-role host_test_idempotency host 

#Func and simply expanded variables
ROLE := $(shell basename ${PWD})

ansible_config:
	printf '[defaults]\nroles_path=../\n[privilege_escalation]\nbecome=True\nbecome_method=sudo\nbecome_user=root' > ./ansible.cfg

host_syntax_check: ansible_config
	ansible-playbook ./tests/test.yml -i ./tests/inventory --syntax-check

host_test-role: host_syntax_check
	ansible-playbook ./tests/test.yml -i ./tests/inventory --connection=local

host_test_idempotency: host_test-role
	ansible-playbook ./tests/test.yml -i ./tests/inventory --connection=local \
		| tee /tmp/output.txt; grep -q 'changed=0.*failed=0' /tmp/output.txt \
		|| (echo "Exit status not 0" && exit 1)

host: host_test_idempotency
	rm -f ./ansible.cfg
	@echo "All fine."



