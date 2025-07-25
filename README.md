# Jupyter mlcloud
Some script to use the mlcloud cluster via jupyter-lab(notebook).

## Step 1 (Server)
Under the `$HOME` directory (e.g., `/home/<prof-name>/<your-id>/`), copy the private key you have authorized into the `.ssh` folder (i.e., `$HOME/.ssh`).
This step is necessary to manually log in to the computational node from the login node.

## Step 2 (Server)
Copy the `notebook.sh` script into your `$WORK` directory (e.g., `/mnt/lustre/work/<prof-name>/<your-id>`).
`notebook.sh` is a standard SBATCH script that allocates resources.
Here are the settings:
```sh
#SBATCH --job-name=notebook                                                     # Job name
#SBATCH --ntasks=1                                                              # Number of tasks
#SBATCH --cpus-per-task=8                                                       # Number of CPU cores per task
#SBATCH --nodes=1                                                               # Ensure that all cores are on the same machine with nodes=1
#SBATCH --partition=<node-partition>                                            # Which partition will run your job
#SBATCH --time=0-01:00                                                          # Allowed runtime in D-HH:MM
#SBATCH --gres=gpu:1                                                            # (optional) Requesting type and number of GPUs
#SBATCH --mem=32G                                                               # Total memory pool for all cores (see also --mem-per-cpu); exceeding this number will cause your job to fail.
#SBATCH --output=/mnt/lustre/work/<prof-name>/<your-id>/logs/myjob-%j.out       # File to which STDOUT will be written - make sure this is not on $HOME
#SBATCH --error=/mnt/lustre/work/<prof-name>/<your-id>/logs/myjob-%j.err        # File to which STDERR will be written - make sure this is not on $HOME
#SBATCH --mail-type=ALL                                                         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=<your-email>                                                # Email to which notifications will be sent
```

As a safety measure, set a reasonable maximum time (currently set to 1 hour) so that even if you forget to close the Jupyter Notebook manually, the session will automatically terminate without leaving a job running for days.
Set the `node-partition` (e.g., `a100-galvani`), as well as your professor's name and your ID, to specify the paths for the log and error directories.
These files will be used to extract the Jupyter Notebook link.
Additionally, you can specify your email to receive notifications when the job starts and ends.
The last part of the script activates the local Python [`uv`](https://docs.astral.sh/uv/) virtual environment and starts the Jupyter Notebook:
```sh
cd $WORK/<repo> && source .venv/bin/activate && jupyter-lab --no-browser --port 8080
```
Adjust this part depending on your Python setup.

## Step 4 (Client)
Add the following alias to your local `.bashrc` or `.zshrc` file:
```sh
jupyter-mlcloud() {
  JOB_ID=$(echo $(ssh -t <your-id>@<cluster-login-node> -p <port> 'sbatch $WORK/notebook.sh') | grep -o '[0-9]\+')
  sleep 3s
  NODE_HOST=$(echo $(ssh -t <your-id>@<cluster-login-node> -p <port> 'squeue --me') | grep -o '\bgalvani[^ ]*' | tr -cd '[:print:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  sleep 5s
  JUPYTER_URL=$(ssh -t <your-id>@<cluster-login-node> -p <port> "grep -E '^[[:space:]]*http://localhost:8080/' /mnt/lustre/work/<prof-name>/<your-id>/logs/myjob-${JOB_ID}.err" \
    | sed 's/^[[:space:]]*//')
  echo -e "\e[1;32m${JUPYTER_URL}\e[0m"
  ssh -AtL 8080:localhost:8080 <your-id>@<cluster-login-node> -p <port> "ssh -AtL 8080:localhost:8080 <your-id>@$NODE_HOST bash"
}
```

Replace all placeholders enclosed in `<>` with your actual information.
The script automatically runs `notebook.sh` on the login node, fetches the computational node ID and the Jupyter Notebook link, and then SSHs into the computational node via the login node, tunneling port `8080` twice to enable access to Jupyter in your browser.
The fetched Jupyter Notebook link will be printed in the terminal.  
Simply copy and paste it into your browser to start working.
