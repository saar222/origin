import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser(description='Generate plant growth charts')
parser.add_argument('--plant', type=str, required=True, help='Name of the plant')
parser.add_argument('--height', type=str, required=True, help='Height measurements')
parser.add_argument('--leaf_count', type=str, required=True, help='Leaf count measurements')
parser.add_argument('--dry_weight', type=str, required=True, help='Dry weight measurements')

args = parser.parse_args()
plant = args.plant
# Convert height to list of integers
height_data = [int(h) for h in args.height.split()]
# Convert leaf_count to list of integers
leaf_count_data = [int(lc) for lc in args.leaf_count.split()]
# Convert dry_weight to list of floats
dry_weight_data = [float(dw) for dw in args.dry_weight.split()]
# Generate weeks based on the number of measurements
weeks = [f'Week {i+1}' for i in range(len(height_data))]

print(f"Plant: {plant}")
print(f"Height data: {height_data} cm")
print(f"Leaf count data: {leaf_count_data}")
print(f"Dry weight data: {dry_weight_data} g")

# Scatter Plot - Height vs Leaf Count
plt.figure(figsize=(10, 6))
plt.scatter(height_data, leaf_count_data, color='b')
plt.title(f'Height vs Leaf Count for {plant}')
plt.xlabel('Height (cm)')
plt.ylabel('Leaf Count')
plt.grid(True)
plt.savefig(f"{plant}_scatter.png")
plt.close()

# Histogram - Distribution of Dry Weight
plt.figure(figsize=(10, 6))
plt.hist(dry_weight_data, bins=len(dry_weight_data), color='g', edgecolor='black')
plt.title(f'Histogram of Dry Weight for {plant}')
plt.xlabel('Dry Weight (g)')
plt.ylabel('Frequency')
plt.grid(True)
plt.savefig(f"{plant}_histogram.png")
plt.close()

# Line Plot - Plant Height Over Time
plt.figure(figsize=(10, 6))
plt.plot(weeks, height_data, marker='o', color='r')
plt.title(f'{plant} Height Over Time')
plt.xlabel('Week')
plt.ylabel('Height (cm)')
plt.grid(True)
plt.savefig(f"{plant}_line_plot.png")
plt.close()

print(f"Generated plots for {plant}:")
print(f"Scatter plot saved as {plant}_scatter.png")
print(f"Histogram saved as {plant}_histogram.png")
print(f"Line plot saved as {plant}_line_plot.png")
