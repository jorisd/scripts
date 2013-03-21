delete from baie;
insert into baie (baie_id, name, dc_id) values (1, "baie1dc1", 1);
insert into baie (baie_id, name, dc_id) values (2, "baie2dc1", 1);
insert into baie (baie_id, name, dc_id) values (3, "baie3dc1", 1);
insert into baie (baie_id, name, dc_id) values (4, "baie1dc2", 2);
insert into baie (baie_id, name, dc_id) values (5, "baie2dc2", 2);
insert into baie (baie_id, name, dc_id) values (6, "baie3dc2", 2);

delete from host;
insert into host (host_id, ip, ram, disk, name, baie, active) values (1, "10.0.0.1", 16, 500, "srv001dc1", 1, 1);
insert into host (host_id, ip, ram, disk, name, baie, active) values (2, "20.0.0.1", 16, 500, "srv001dc2", 4, 0);
insert into host (host_id, ip, ram, disk, name, baie, active) values (3, "10.0.0.2", 16, 500, "srv002dc1", 1, 1);
insert into host (host_id, ip, ram, disk, name, baie, active) values (4, "20.0.0.1", 16, 500, "srv002dc2", 4, 0);

delete from vm;
insert into vm(vm_id, ip, ip_service, ram, disk, name) values (1, "10.1.0.1", "93.23.12.11", 2, 40, "client1");
insert into vm(vm_id, ip, ip_service, ram, disk, name) values (2, "20.1.0.1", "93.23.12.11", 2, 40, "client1");
insert into vm(vm_id, ip, ip_service, ram, disk, name) values (3, "10.1.0.2", "93.23.12.12", 2, 40, "client2");
insert into vm(vm_id, ip, ip_service, ram, disk, name) values (4, "20.1.0.2", "93.23.12.12", 2, 40, "client2");

delete from host_pairs;
insert into host_pairs (host_id1, host_id2) values (1,2);
insert into host_pairs (host_id1, host_id2) values (3,4);

