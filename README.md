# Artifact Evaluation for "CSAL: the Next-Gen Local Disks for the Cloud" ([EuroSys 2024 AE](https://sysartifacts.github.io/eurosys2024/))

## 1. Introduction
This Artifact Evaluation pertains to "[CSAL: the Next-Gen Local Disks for the Cloud](https://doi.org/10.1145/3627703.3629566)" accepted by EuroSys 2024. The goal of this Artifact Evaluation is to help you 1) get project source code; 2) rebuild the project from scratch; 3) reproduce the main experimental results.

## 2. Access Source Code
The source code of CSAL has been accepted by SPDK community ([BSD 3-clause license](https://opensource.org/license/bsd-3-clause/)) and merged into SPDK main branch at [Github](https://github.com/spdk/spdk). Within SPDK, CSAL is implemented as a module of [Flash Translation Layer](https://spdk.io/doc/ftl.html). You can find CSAL implementation under the folder "[spdk/lib/ftl](https://github.com/spdk/spdk/tree/master/lib/ftl)" as follows:
```
lib/ftl
├── ftl_band.c
├── ftl_band.h
├── ftl_band_ops.c
├── ftl_core.c
├── ftl_core.h
├── ftl_debug.c
├── ftl_debug.h
├── ftl_init.c
├── ftl_internal.h
├── ftl_io.c
├── ftl_io.h
├── ftl_l2p.c
├── ftl_l2p_cache.c
├── ftl_l2p_cache.h
├── ftl_l2p_flat.c
├── ftl_l2p_flat.h
├── ftl_l2p.h
├── ftl_layout.c
├── ftl_layout.h
├── ftl_nv_cache.c
├── ftl_nv_cache.h
├── ftl_nv_cache_io.h
├── ftl_p2l.c
├── ftl_reloc.c
├── ftl_rq.c
├── ftl_sb.c
├── ftl_sb_common.h
├── ftl_sb_current.h
├── ftl_sb.h
├── ftl_trace.c
├── ftl_trace.h
├── ftl_utils.h
├── ftl_writer.c
├── ftl_writer.h
├── Makefile
├── mngt
│   ├── ftl_mngt_band.c
│   ├── ftl_mngt_bdev.c
│   ├── ftl_mngt.c
│   ├── ftl_mngt.h
│   ├── ftl_mngt_ioch.c
│   ├── ftl_mngt_l2p.c
│   ├── ftl_mngt_md.c
│   ├── ftl_mngt_misc.c
│   ├── ftl_mngt_p2l.c
│   ├── ftl_mngt_recovery.c
│   ├── ftl_mngt_self_test.c
│   ├── ftl_mngt_shutdown.c
│   ├── ftl_mngt_startup.c
│   ├── ftl_mngt_steps.h
│   └── ftl_mngt_upgrade.c
├── spdk_ftl.map
├── upgrade
│   ├── ftl_band_upgrade.c
│   ├── ftl_chunk_upgrade.c
│   ├── ftl_layout_upgrade.c
│   ├── ftl_layout_upgrade.h
│   ├── ftl_p2l_upgrade.c
│   ├── ftl_sb_prev.h
│   ├── ftl_sb_upgrade.c
│   └── ftl_sb_upgrade.h
└── utils
    ├── ftl_addr_utils.h
    ├── ftl_bitmap.c
    ├── ftl_bitmap.h
    ├── ftl_conf.c
    ├── ftl_conf.h
    ├── ftl_defs.h
    ├── ftl_df.h
    ├── ftl_log.h
    ├── ftl_md.c
    ├── ftl_md.h
    ├── ftl_mempool.c
    └── ftl_mempool.h
```

Note: any SPDK application (e.g., vhost, nvmf_tgt, iscsi_tht) can use CSAL to construct a block-level cache for storage acceleration. In the following case, we will use vhost as an example that is the same as our EuroSys paper.

## 3. Kick-the-tire Instructions (10+ minutes)
### Overview
![Figure](/others/figure.png)

The figure above describes the high level architecture of what we will build in this guide. First, we construct a CSAL block device (the green part in the figure). Second, we start a vhost target and assign this CSAL block device to vhost (the yellow part in figure). Third, we launch a virtual machine (the blue part in figure) that communicates with the vhost target. Finally, you will get a virtual disk in the VM. The virtual disk is accelerated by CSAL.

### Prerequisites
#### Environment Check-List
- OS: Linux kernel >= 3.10.0
- Compilation:
  - GCC 4.9.4
  - Python 3.12.0
- Storage:
  - NVMe QLC SSD
  - NVMe Optane SSD or SLC SSD with VSS capability (4K + 64B format)
- Memory: at least 30GB DRAM.

 QLC SSD will be used as capacity device (denoted as /dev/nvme0n1 in the following instructions) while Optane/SLC SSD (denoted as /dev/nvme1n1 in the following instructions) will be used as cache device.
  
#### Preparing SPDK
1. Get the source code
   ```bash
   $ git clone https://github.com/spdk/spdk
   $ cd spdk
   # switch to a formal release version (e.g., v22.09)
   $ git checkout v22.09
   # get correct DPDK version
   $ git submodule update --init
   ```

2. Compile SPDK
   ```bash
   $ sudo scripts/pkgdep.sh # install prerequisites
   $ ./configure
   $ make
   ```

3. Format SSD  
   For both cache device and capacity device, set sector size to 4KB with nvme-cli tool:
   ```bash
   # install nvme-cli
   $ yum install nvme-cli -y
   $ nvme format /dev/nvme0n1 -b 4096 --force
   $ nvme format /dev/nvme1n1 -b 4096 --force
   ```

4. Enable VSS for cache device
   ```bash
   $ nvme format /dev/nvme1 --namespace-id=1 --lbaf=4 --force --reset
   ```
   The SSD will be formatted into the layout with 4KB data sector followed by 64B metadata area.  

5. Enable VSS emulation (optional for Non-VSS SSD):  
   If you do not have fast NVMe device that supports VSS, you can use CSAL VSS software emulation to run performance testing and study. Note that emulation does not promise power safety and crash consistency To build CSAL with VSS software emulation support, please modify the below Makefile:
   ```bash
   $ vim lib/ftl/Makefile
   # find below definition SPDK_FTL_VSS_EMU
   ifdef SPDK_FTL_VSS_EMU
   CFLAGS += -DSPDK_FTL_VSS_EMU
   endif
   ```
   Enable SPDK_FTL_VSS_EMU macro by commenting out the "ifdef" and "endif" as below and then recompile:
   ```bash
   #ifdef SPDK_FTL_VSS_EMU
   CFLAGS += -DSPDK_FTL_VSS_EMU
   #endif

   # recompile:
   $ make
   ```

6. Configure huge pages (reserve 20GB DRAM) 
   We reserve 20GB DRAM as huge pages: 16GB+ for VM and 2GB+ for CSAL (others for SPDK runtime):
   ```bash
   $ sudo HUGEMEM=20480 ./scripts/setup.sh
   ```

#### Building the SPDK Application with CSAL
1. Start SPDK vhost target
   ```bash
   # start vhost on CPU 0 and 1 (cpumask 0x3)
   $ sudo build/bin/vhost -S /var/tmp -m 0x3

   Starting SPDK v22.09 git sha1 aed4ece / DPDK 22.07.0 initialization...
   [ DPDK EAL parameters: xxxx]
   TELEMETRY: No legacy callbacks, legacy socket not created
   spdk_app_start: *NOTICE*: Total cores available: 2
   reactor_run: *NOTICE*: Reactor started on core 1
   reactor_run: *NOTICE*: Reactor started on core 0
   sw_accel_module_init: *NOTICE*: Accel framework software module initialized.
   ```
   After successfully starting vhost target, please open a new terminate to construct CSAL as follows.
 
2. Construct CSAL block device (use 2GB+ Huge Pages)
   
   ```bash
   # Before starting the following instructions, you should get
   # your NVMe devices' BDF number. In the following case, you get
   # two NVMe devices with BDF 0000:00:05.0 and 0000:00:06.0, respectively.
   $ lspci | grep -i non
   00:05.0 Non-Volatile memory controller: xxx
   00:06.0 Non-Volatile memory controller: xxx
   
   # construct capacity device NVMe0 with BDF "0000:00:05.0"
   $ scripts/rpc.py bdev_nvme_attach_controller -b nvme0 -t PCIe -a 0000:00:05.0
   nvme0n1

   # construct cache device NVMe1 with BDF "0000:00:06.0"
   $ scripts/rpc.py bdev_nvme_attach_controller -b nvme1 -t PCIe -a 0000:00:06.0
   nvme1n1

   # construct CSAL device FTL0 on top of nvme0n1 and nvme1n1. This process
   # will take a bit more time to scrub cache. The time depends on the capacity
   # of you cache device. Now we limit L2P cache in DRAM to 2048MB and 
   # overprovisioning to 18% of capacity device, and use same CPU core 
   # with vhost. You can use "--help" to check deatiled parameter explaination.
   $ scripts/rpc.py bdev_ftl_create -b FTL0 -d nvme0n1 -c nvme1n1 --overprovisioning 18 --l2p-dram-limit 2048 --core-mask 0x3

   # The above RPC call may fail because of timeout, which doesn't matter. 
   # You can check vhost output. When scrubbing cache, the output will be like:
   ftl_mngt_scrub_nv_cache: *NOTICE*: [FTL][FTL0] First startup needs to scrub nv cache data region, this may take some time.
   ftl_mngt_scrub_nv_cache: *NOTICE*: [FTL][FTL0] Scrubbing 3517GiB

   # Besides, you can also use SPDK iostat to see the CSAL is scrubbing cache device:
   $ ./scripts/iostat.py -d -m -t 300 -i 1
   Device   tps     MB_read/s  MB_wrtn/s  MB_dscd/s  MB_read  MB_wrtn  MB_dscd
   nvme0n1  0.00    0.00       0.00       0.00       0.00     0.00     0.00
   nvme1n1  898.18  0.00       3592.73    0.00       0.00     3608.00  0.00

   # When CSAL constrction finish, vhost output will be like:
   [FTL][FTL0] Management process finished, name 'FTL startup', duration = 1006831.750 ms, result 0

   ```

3. Split the disk into multiple partitions
   ```bash
   $ scripts/rpc.py bdev_split_create FTL0 8
   FTL0p0 FTL0p1 FTL0p2 FTL0p3 FTL0p4 FTL0p5 FTL0p6 FTL0p7
   ```
   Now you have 8 logic partitions based on FTL0. They are FTL0p0, FTL0p1, ..., FTL0p7.

4. Construct vhost-blk controller with CSAL block device  
   To simplify the construction process, we suggest you use vhost-blk to construct VM. Here is an example of how to construct vhost-blk controller with one partition.
   ```bash
   # The following RPC command creates a vhost-blk device that 
   # exposes the FTL0 device. The device will be accessible to QEMU 
   # via /var/tmp/vhost.1. All the I/O polling will be pinned to the 
   # least occupied CPU core within the given cpumask; in this case, 
   # always CPU 0.
   $ scripts/rpc.py vhost_create_blk_controller --cpumask 0x1 vhost.1 FTL0p0

   # vhost output will be like:
   VHOST_CONFIG: (/var/tmp/vhost.1) logging feature is disabled in async copy mode
   VHOST_CONFIG: (/var/tmp/vhost.1) vhost-user server: socket created, fd: 275
   VHOST_CONFIG: (/var/tmp/vhost.1) binding succeeded
   ```
   Now the vhost target with a logic partition of CSAL block device is ready. You can launch qemu to connect this socket (i.e., vhost.1).

5. Launch a virtual machine using QEMU (use 16GB+ Huge Pages)
   ```bash
   $ qemu-system-x86_64 -m 16384 -smp 64 -cpu host -enable-kvm \
      -hda /path/to/centos.qcow2 \ 
      -netdev user,id=net0,hostfwd=tcp::32001-:22 \
      -device e1000,netdev=net0 -display none -vga std \
      -daemonize -pidfile /var/run/qemu_0 \
      -object memory-backend-file,id=mem,size=16G,mem-path=/dev/hugepages,share=on \
      -numa node,memdev=mem \ 
      -chardev socket,id=char0,path=/var/tmp/vhost.1 \
      -device vhost-user-blk-pci,num-queues=8,id=blk0,chardev=char0 \
   ```
   Notes:
      - log into your VM via "ssh root@localhost -p 32001"
      - please change "/path/to/centos.qcow2" to your image path
      - please change path to the actual vhost path from vhost app log

6. Check your VM  
   After successfully logging into your VM, you can find the virtual block device using "lsblk" command as follows:
   ```bash
   $ lsblk
   NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   vda     253:0    0   40G  0 disk
   └─vda1  253:1    0   40G  0 part /
   vdb     259:3    0 12.5T  0 disk
   ``` 
   Note: vda is system disk; the subsequent disks are the data disks (e.g., vdb). 
   
7. Create more VMs  
   If you want to create more virtual disks for different VMs, please repeat step 4, 5, and 6. **In our experiments, we create 8 virtual disks and assign each to a VM. Or you can assign all 8 partitions to one VM for simplicity.**
   
#### Building fio_plugin with CSAL (optional)
We provide another alternative to evaluate CSAL in host server with fio_plugin tool. The following instructions introduce how to build the fio_plugin tool with CSAL. **We do not suggest using fio_plugin with CSAL for evaluation since fio will construct CSAL block device every time when you start fio job. This will take long time.**

1. Compile fio tool
   ```bash
   $ git clone https://github.com/axboe/fio
   $ cd fio
   $ make
   ```

2. Recompile SPDK
   ```bash
   $ cd spdk
   $ ./configure --with-fio=/root/fio # change the path to your fio folder
   $ make
   ```

3. Get fio configuration file  
   Get fio configuration file (i.e., csal.json) from this repository:
   ```bash
   $ git clone https://github.com/ARDICS/CSAL_Artifact_Evaluation.git
   ```
   Note: csal.json is the SPDK bdev construction description file for fio_plugin tool. The SPDK engine inside fio_plugin will use this description to construct block devices. Now we use it to construct CSAL block device (FTL0) with nvme0n1 (0000:00:05.0) and nvme1n1 (0000:00:06.0). You can modify csal.json for whatever block device you want to construct.

4. Launch fio_plugin tool
   ```bash
   # LD_PRELOAD=<path to spdk>/build/fio/spdk_bdev <path to fio>/fio <path to AE_CSAL>/fiotest.job
   $ LD_PRELOAD=/root/spdk/build/fio/spdk_bdev /root/fio/fio /root/AE_CSAL/fiotest.job
   ```
   Note that, in fiotest.job, please modify SPDK path of "ioengine" and csal.json path of "spdk_json_conf" to your own addresses.

Now, you already successfully launch fio_plugin tool with CSAL block device. Then, you can modify general parameters of fio to evaluate any workloads you want (e.g., the following workloads in experiments).

## 4. Evaluation Instructions (50+ hours)
### Experimental Environment
To reproduce the same experimental results as ours, please use the following environment as far as possible.
- OS: Linux CentOS Kernel 4.19
- CPU: 2x Intel 8369B @ 2.90GHz
- Memory: 512GB DDR4 Memory
- NVMe SSDs:
  - 1x Intel P5800X 800GB NVMe SSD (for cache)
  - 1x Intel/Solidigm P5316 15.36TB NVMe SSD
- VM:
  - OS: Linux CentOS Kernel 3.10.0
  - CPU: 56 vCPU cores
  - Memory: 216GB

For simplicity, in the following instructions, we assume you assign all partitions to one VM, so that we can evaluate within one VM on multiple virtual disks (i.e., vdb, vdc, vde, ..., vdi).

### Prerequisites (10+ hours)
#### Preconditioning SSD
To execute the following instructions, you have to log into the VM first. Before starting evaluation, we should precondition the disks in order to make them enter "stable state". The folder "precondition" in our Artifact Evaluation repository includes a script to precondition disks. You can use this configuration and follow the following instructions.
```bash
$ yum install fio -y
$ git clone https://github.com/ARDICS/CSAL_Artifact_Evaluation.git
$ sh precondition/start.sh
```
This will take a long time (around 10 hours) to precondition virtual disks by sequentially writing to the whole space twice, followed by random writes across the entire space.

### Reproducing Figures 10, 11, 12 (40+ hours)
First, to reproduce **figure 10**, you could execute the following instructions (20+ hours):
```bash
$ sh raw/uniform/start.sh
```
The results will be generated in "raw/uniform/results_rnd_workloads" and "raw/uniform/results_seq_workloads" folders. The output of each case should be as follows. You can find write throughput is 2228MB/s (all partitions included) in this example.
```bash
job1: (g=0): rw=write, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=128
job2: (g=0): rw=write, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=128
job3: (g=0): rw=write, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=128
job4: (g=0): rw=write, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=128
job5: (g=0): rw=write, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=128
job6: (g=0): rw=write, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=128
job7: (g=0): rw=write, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=128
job8: (g=0): rw=write, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=128
fio-3.7
Starting 8 processes

job1: (groupid=0, jobs=8): err= 0: pid=26050: Thu Sep 28 00:32:22 2023
  write: IOPS=544k, BW=2125MiB/s (2228MB/s)(374GiB/180230msec)
    slat (nsec): min=1425, max=511061k, avg=13955.15, stdev=1180249.41
    clat (usec): min=22, max=514231, avg=1868.26, stdev=13315.29
     lat (usec): min=213, max=514254, avg=1882.30, stdev=13367.67
    clat percentiles (usec):
     |  1.00th=[   322],  5.00th=[   474], 10.00th=[   603], 20.00th=[   914],
     | 30.00th=[  1090], 40.00th=[  1221], 50.00th=[  1336], 60.00th=[  1467],
     | 70.00th=[  1631], 80.00th=[  1893], 90.00th=[  2376], 95.00th=[  2868],
     | 99.00th=[  4015], 99.50th=[  4621], 99.90th=[ 56886], 99.95th=[476054],
     | 99.99th=[501220]
   bw (  KiB/s): min= 4136, max=1094408, per=12.52%, avg=272298.64, stdev=137941.19, samples=2880
   iops        : min= 1034, max=273602, avg=68074.65, stdev=34485.30, samples=2880
  lat (usec)   : 50=0.01%, 250=0.01%, 500=7.17%, 750=6.37%, 1000=10.66%
  lat (msec)   : 2=58.75%, 4=16.03%, 10=0.78%, 20=0.14%, 50=0.01%
  lat (msec)   : 100=0.01%, 250=0.02%, 500=0.06%, 750=0.01%
  cpu          : usr=4.61%, sys=23.97%, ctx=10747928, majf=0, minf=44
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=174.8%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,98032582,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=128

Run status group 0 (all jobs):
  WRITE: bw=2125MiB/s (2228MB/s), 2125MiB/s-2125MiB/s (2228MB/s-2228MB/s), io=374GiB (402GB), run=180230-180230msec
```

Second, to reproduce **figure 11**, you could execute the following instructions (10+ hours):
```bash
$ sh raw/skewed/start.sh
```
The results will be generated in "raw/skewed/results" folder.

Third, to reproduce **figure 12**, you could execute the following instructions (10+ hours):
```bash
$ sh /raw/mixed/start.sh
```
The results will be generated in "raw/mixed/results" folder. The read and write results are separate in the outputs of each case.

### Reproducing Figures 13 (20+ minues)
To reproduce figure 13, we need to run the same workloads as those in figure 11. To measure the write amplification factor (WAF), we should execute the following test cases and calculate WAF one by one.
```bash
# for 4KB skewed workloads (i.e., Figure 11(a))
$ fio raw/skewed/fio_4k_zipf0.8.job
$ fio raw/skewed/fio_4k_zipf1.2.job

# for 64KB skewed workloads (i.e., Figure 11(b))
$ fio raw/skewed/fio_64k_zipf0.8.job
$ fio raw/skewed/fio_64k_zipf1.2.job
```
The write amplification factor (WAF) is calculated by dividing the total size of NAND writes by the total size of logical writes. Before and after each test, you can use the nvme-cli tool to retrieve the current NAND writes of the QLC drive (ensure you do this in the HOST, not the VM). Upon completion, fio will report the total logical writes. Here's how to use the nvme-cli tool to retrieve NAND writes:
```bash
$ nvme smart-log /dev/nvme0n1
```
In the output, you can find current data read and written on NAND media from "data_units_read" and "data_units_written" fields.

### Reproducing Figures 14 (5+ minutes)
To reproduce figure 14, execute the 4k random writes workload as follows:
```bash
$ fio raw/uniform/fio_rnd_4k.job
```
During the test, you can use the spdk iostat tool to monitor the CASL backend traffic for each block device (ensure this is done in the HOST, not the VM).
```bash
$ cd ~/path/to/spdk
$ yum install python3 -y
$ scripts/spdk_iostat -d -m -i 1 -t 3000
```

## 5. License
CSAL follows the same license with SPDK ([BSD 3-clause](https://opensource.org/license/bsd-3-clause/)). You can use CSAL to make comparison under BSD 3-clause license. For this Artifact Evaluation repository, we use [MIT](https://opensource.org/license/mit/) license.

## 6. Others
We have now implemented a new approach that doesn't rely on the VSS capability for the cache layer. In subsequent releases, you'll be able to construct CSAL on devices without VSS.

For any other help, please contact SPDK community.