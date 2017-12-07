# driver bash script to exectute urchin selection experiment analysis
# the following executes data analysis following filtering

DATE=`date +%Y-%m-%d`
now=$(date +"%T")

echo "data analysis script run on ${DATE} at ${now}"

Rscript ~/urchin_af/scripts/AF_change.R 2> ~/urchin_af/log_out/AF_change.stderr_$(date +"%F_%R").txt 1> ~/urchin_af/log_out/AF_change.stdout_$(date +"%F_%R").txt

wait $!

if [ $? -eq 0 ]
then
  echo "cmh analysis successful"
  exit 0
else
  echo "cmh analysis failed"
  exit 1
fi
#sort cmh output:
cat ~/urchin_af/analysis/cmh.out.txt | sort -k1,1 -k2,2n > ~/urchin_af/analysis/cmh.out.sorted.txt

# prep files for ldx
# isolate each group for comparisons. get bam out. these should be around 15g total.
samtools view -H /data/OASV2/merged.fixmate.sorted.bam > ~/urchin_af/variants/sam.header

samtools view /data/OASV2/merged.fixmate.sorted.bam   | grep 'OASV2_DNA_D1.*' | cat ~/urchin_af/variants/sam.header - | samtools view -Sb > ~/urchin_af/variants/D1.bam

samtools view /data/OASV2/merged.fixmate.sorted.bam   | grep 'OASV2_DNA_D7_8_0.*' | cat ~/urchin_af/variants/sam.header - | samtools view -Sb > ~/urchin_af/variants/D7_8.bam

samtools view /data/OASV2/merged.fixmate.sorted.bam   | grep 'OASV2_DNA_D7_7_5.*' | cat ~/urchin_af/variants/sam.header - | samtools view -Sb > ~/urchin_af/variants/D7_7.bam

bash ld.sh 2> ~/urchin_af/log_out/ld_stderr_$(date +"%F_%R").txt 1> ~/urchin_af/log_out/ld_stdout_$(date +"%F_%R").txt

wait $!

if [ $? -eq 0 ]
then
  echo "ldx successful"
  exit 0
else
  echo "ldx failed"
  exit 1
fi
# plot ld results

Rscript ~/urchin_af/scripts/ld.R 2> ~/urchin_af/log_out/depth_filt.stderr_$(date +"%F_%R").txt 1> ~/urchin_af/log_out/depth_filt.stdout_$(date +"%F_%R").txt

wait $!

if [ $? -eq 0 ]
then
  echo "ldx plotting successful"
  exit 0
else
  echo "ldx plotting failed"
  exit 1
fi
# variance in af

Rscript ~/urchin_af/scripts/af_variance.R 2> ~/urchin_af/log_out/af_variance.stderr_$(date +"%F_%R").txt 1> ~/urchin_af/log_out/af_variance.stdout_$(date +"%F_%R").txt

wait $!

if [ $? -eq 0 ]
then
  echo "allele freq variance calc successful"
  exit 0
else
  echo "allele freq variance calc failed"
  exit 1
fi