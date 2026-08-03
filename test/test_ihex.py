def calculate_checksum(byte_count, address, record_type, data):
    # Sum up the metadata fields and payload bytes
    record_sum = byte_count + (address >> 8) + (address & 0xFF) + record_type
    for b in data:
        record_sum += b
    # Return two's complement of the lowest byte
    return (-record_sum) & 0xFF

def generate_ihex_line(address, data):
    byte_count = len(data)
    record_type = 0x00
    checksum = calculate_checksum(byte_count, address, record_type, data)
    
    # Format line: :[Length][Address][Type][Data...][Checksum]
    hex_str = f":{byte_count:02X}{address:04X}{record_type:02X}"
    for b in data:
        hex_str += f"{b:02X}"
    hex_str += f"{checksum:02X}"
    return hex_str

# Generate 10,240 bytes of data (exactly 320 records of 32 bytes each)
total_bytes = 10240
bytes_per_line = 32
ihex_lines = []

current_address = 0x0000
for i in range(0, total_bytes, bytes_per_line):
    # Creates shifting dummy byte patterns for diagnostic readability
    data_payload = [(i // bytes_per_line + j) & 0xFF for j in range(bytes_per_line)]
    ihex_lines.append(generate_ihex_line(current_address, data_payload))
    current_address += bytes_per_line

# Append the explicit, valid End of File (EOF) record
ihex_lines.append(":00000001FF")

# Write to disk
with open("test_10kb.hex", "w") as f:
    f.write("\n".join(ihex_lines) + "\n")

print("File 'test_10kb.hex' created successfully with valid EOF record.")

