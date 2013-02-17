insert into host (host_id, ip, ram, disk, name, dc, active) values (1, "10.0.0.1", 16, 500, "srv001dc1", 1, 1);
insert into host (host_id, ip, ram, disk, name, dc, active) values (2, "20.0.0.1", 16, 500, "srv001dc2", 2, 0);
insert into host (host_id, ip, ram, disk, name, dc, active) values (3, "10.0.0.2", 16, 500, "srv002dc1", 1, 1);
insert into host (host_id, ip, ram, disk, name, dc, active) values (4, "20.0.0.1", 16, 500, "srv002dc2", 2, 0);


insert into vm(vm_id, ip, ip_service, ram, disk, name, dc, active) values (1, "10.1.0.1", "93.23.12.11", 2, 40, "client1", 1, 1);
insert into vm(vm_id, ip, ip_service, ram, disk, name, dc, active) values (2, "20.1.0.1", "93.23.12.11", 2, 40, "client1", 2, 0);
insert into vm(vm_id, ip, ip_service, ram, disk, name, dc, active) values (3, "10.1.0.2", "93.23.12.12", 2, 40, "client2", 1, 1);
insert into vm(vm_id, ip, ip_service, ram, disk, name, dc, active) values (4, "20.1.0.2", "93.23.12.12", 2, 40, "client2", 2, 0);

insert into host_pairs (host_id1, host_id2) values (1,2);
insert into host_pairs (host_id1, host_id2) values (3,4);
