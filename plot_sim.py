import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('simulations/sim_log.csv')

plt.figure(figsize=(10,4))
plt.step(df['time_ns'], df['state'], where='post', label='FSM State')
plt.plot(df['time_ns'], df['cnt_ov'], label='cnt_ov')
plt.plot(df['time_ns'], df['cnt_uc'], label='cnt_uc')
plt.legend()
plt.xlabel('Time (ns)')
plt.ylabel('Value')
plt.title('FSM Simulation Results')
plt.savefig('simulations/sim_plot.png', dpi=200)
print("Saved simulations/sim_plot.png")
