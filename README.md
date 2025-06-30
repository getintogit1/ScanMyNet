# Network Scanner Automation Script

**A Bash-based solution for automated network host discovery and comprehensive scanning.**

This script streamlines network monitoring by automatically detecting new hosts, performing detailed scans, and enriching results with vendor information. Designed for regulated environments where loud network scans are authorized.

---

## 🚀 Features

* **Host Discovery**: Identifies live hosts via ARP scanning and Nmap ping sweep (`-sn`).
* **Deep Inspection**: Executes advanced Nmap scans (`-A`) to enumerate open ports, running services, OS details, and version info.
* **Vendor Enrichment**: Resolves MAC addresses to vendor names using the [macvendors.com API](https://macvendors.com).
* **Incremental Updates**: Maintains `networkIPs.txt` and `output.txt` to skip already-scanned hosts and results.
* **Continuous Monitoring**: Runs in a loop with a randomized sleep interval, ideal for real-time network oversight.

---

## 🛠️ Prerequisites

Ensure the following tools are installed and that the script runs with root privileges:

* **nmap**: Network exploration and security auditing tool.
* **arp-scan**: Fast ARP-based host discovery utility.
* **curl**: Command-line HTTP client for vendor lookups.
* **bash**: Unix shell and scripting language.

Install dependencies on Debian/Ubuntu:

```bash
sudo apt update && sudo apt install -y nmap arp-scan curl bash
```

---

## 📦 Installation

1. Clone the repository:

   ```bash
   ```

git clone [https://github.com/getintogit1/ScanMyNet.git](https://github.com/getintogit1/ScanMynet.git)
cd network-scanner-automation

````

2. Grant execution permissions:

    ```bash
chmod +x network-scanner.sh
````

---

## ▶️ Usage

```bash
sudo ./network-scanner.sh <target-network>
```

* `<target-network>`: A CIDR range (e.g., `192.168.1.0/24`) or the keyword `local` to scan the primary network interface.

**Example:**

```bash
sudo ./network-scanner.sh 192.168.0.0/24
```

Upon execution, the script generates/updates:

* **networkIPs.txt**: Discovered host IP addresses.
* **output.txt**: Tab-separated summary (`IP`, `MAC`, `PORT`, `STATE`, `SERVICE`, `VERSION`).
* **output\_with\_vendor.txt**: Same summary with an appended `VENDOR` column.

---

## ⚙️ Configuration

* **Scan Interval**: Defaults to a random delay between 20–140 seconds. Modify the `sleep` command in the `main` function to customize.
* **Network Interface**: Auto-detected via the `ip` command. Override by setting the `interface` variable manually.
* **API Rate Limiting**: The vendor lookup delays 3 seconds per request to respect [macvendors.com](https://macvendors.com) rate limits. Replace or optimize as needed.

---

## 📝 Script Breakdown

1. **Privilege Check**: Verifies execution as root (required for ARP and OS detection).
2. **Argument Validation**: Ensures a target network is specified.
3. **ARP Scan**: Uses `arp-scan` to discover new hosts, appending unique IPs to `networkIPs.txt`.
4. **Ping Sweep**: Executes `nmap -sn` when no previous IP list exists.
5. **Detailed Scan**: Runs `nmap -A` against IPs from `networkIPs.txt`, parsing results into `output.txt`.
6. **Vendor Lookup**: Retrieves vendor names for MAC addresses, producing `output_with_vendor.txt`.
7. **Loop**: Continuously repeats discovery and scanning until terminated.


---

## 📄 License

This project is distributed under the [MIT License](LICENSE).

---

> **Disclaimer:** Use this script responsibly. Loud network scans can disrupt network operations and may violate acceptable use policies. Always obtain proper authorization before scanning any network.
