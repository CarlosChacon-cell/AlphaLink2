fasta_path=$1
crosslinks=$2
output_dir_base=$3
param_path=$4
database_dir=$5
max_template_date=$6
recycling_iterations=${7:-20}
number_of_samples=${8:-25}
neff=${9:--1}
dropout_crosslinks=${10:--1}

echo "Starting MSA generation..."
python /apps/AlphaLink/AlphaLink2/unifold/homo_search.py \
    --fasta_path=$fasta_path \
    --max_template_date=$max_template_date \
    --output_dir=$output_dir_base  \
    --uniref90_database_path=${database_dir}AF3/uniref90_2022_05.fa \
    --mgnify_database_path=${database_dir}AF3/mgy_clusters_2022_05.fa \
    --bfd_database_path=${database_dir}AF3/bfd-first_non_consensus_sequences.fasta \
    --uniprot_database_path=${database_dir}AF3/uniprot_all_2021_04.fasta \
    --pdb_seqres_database_path=${database_dir}AF3/pdb_seqres_2022_09_28.fasta \
    --template_mmcif_dir=${database_dir}AF3/mmcif_files \
    --obsolete_pdbs_path=${database_dir}obsolete_pdbs/obsolete.dat \
    --uniclust30_database_path=${database_dir}uniclust30/uniclust30_2018_08/uniclust30_2018_08 \
    --use_precomputed_msas=True

echo "Starting prediction..."
fasta_file=$(basename $fasta_path)
target_name=${fasta_file%.fa*}
python /apps/AlphaLink/AlphaLink2/inference.py \
	--model_name="multimer_af2_crop" \
	--param_path=$param_path \
	--data_dir=$output_dir_base \
	--target_name=$target_name \
	--output_dir=$output_dir_base \
    	--crosslinks=$crosslinks \
	--bf16 \
	--use_uniprot \
        --max_recycling_iters=$recycling_iterations \
        --times=$number_of_samples \
        --neff=$neff \
        --dropout_crosslinks=$dropout_crosslinks \
        --save_raw_output \
	--relax
