python optimizer.py \
    --iter 1000\
    --device cuda\
    --device_num 0\
    --sample_freq 200\
    --warpFeat\
    --warpRes\
    --warpMv\
    --cycle\
    --content_style_wt 0.4 \
    --cycle_wt 1.5 \
    --content_root ./sim_real_inputs/for_the_paper_inputs/sim \
    --style_root ./sim_real_inputs/for_the_paper_inputs/real \
    --save_root ./results/for_the_paper_results/CYC_15_CSW_04_results \
    --fileType jpg\