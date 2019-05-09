########################################################################################################
########################## THRESHOLD 6 Asc ################################################################
####### Threshold 6 PRC Curves
`perl createPRC.pl flippedScores_t1/threshold6_dirCos gold/truth_threshold6 prcCurves_t1/prc_threshold6_dirCos_asc --sortAscending`;
`perl createPRC.pl flippedScores_t1/threshold6_freq gold/truth_threshold6 prcCurves_t1/prc_threshold6_freq_asc --sortAscending`;
`perl createPRC.pl gold/truth_threshold6 gold/truth_threshold6 prcCurves_t1/prc_threshold6_ideal`;
`perl createPRC.pl flippedScores_t1/threshold6_lsa gold/truth_threshold6 prcCurves_t1/prc_threshold6_lsa_asc --sortAscending`;
`perl createPRC.pl flippedScores_t1/threshold6_lta gold/truth_threshold6 prcCurves_t1/prc_threshold6_lta_asc --sortAscending`;
`perl createPRC.pl flippedScores_t1/threshold6_ltc gold/truth_threshold6 prcCurves_t1/prc_threshold6_ltc_asc --sortAscending`;
`perl createPRC.pl flippedScores_t1/threshold6_mwa gold/truth_threshold6 prcCurves_t1/prc_threshold6_mwa_asc --sortAscending`;
`perl createPRC.pl flippedScores_t1/threshold6_sbc gold/truth_threshold6 prcCurves_t1/prc_threshold6_sbc_asc --sortAscending`;
`perl createPRC.pl flippedScores_t1/threshold6_w2vCos gold/truth_threshold6 prcCurves_t1/prc_threshold6_w2vCos_asc --sortAscending`;
`perl createPRC.pl gold/truth_threshold6 gold/truth_threshold6 prcCurves_t1/prc_threshold6_random --random`;


######## Threshold 6 Precision at K
`perl createPrecisionAtK.pl flippedScores_t1/threshold6_dirCos gold/truth_threshold6 precisionAtK_t1/pak_threshold6_dirCos_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores_t1/threshold6_freq gold/truth_threshold6 precisionAtK_t1/pak_threshold6_freq_asc --sortAscending`;
`perl createPrecisionAtK.pl gold/truth_threshold6 gold/truth_threshold6 precisionAtK_t1/pak_threshold6_ideal`;
`perl createPrecisionAtK.pl flippedScores_t1/threshold6_lsa gold/truth_threshold6 precisionAtK_t1/pak_threshold6_lsa_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores_t1/threshold6_lta gold/truth_threshold6 precisionAtK_t1/pak_threshold6_lta_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores_t1/threshold6_ltc gold/truth_threshold6 precisionAtK_t1/pak_threshold6_ltc_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores_t1/threshold6_mwa gold/truth_threshold6 precisionAtK_t1/pak_threshold6_mwa_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores_t1/threshold6_sbc gold/truth_threshold6 precisionAtK_t1/pak_threshold6_sbc_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores_t1/threshold6_w2vCos gold/truth_threshold6 precisionAtK_t1/pak_threshold6_w2vCos_asc --sortAscending`;
`perl createPrecisionAtK.pl gold/truth_threshold6 gold/truth_threshold6 precisionAtK_t1/pak_threshold6_random --random`;


########################## THRESHOLD 6 Desc

####### Threshold 6 PRC Curves
`perl createPRC.pl scores_t1/threshold6_dirCos gold/truth_threshold6 prcCurves_t1/prc_threshold6_dirCos `;
`perl createPRC.pl scores_t1/threshold6_freq gold/truth_threshold6 prcCurves_t1/prc_threshold6_freq `;
`perl createPRC.pl gold/truth_threshold6 gold/truth_threshold6 prcCurves_t1/prc_threshold6_ideal`;
`perl createPRC.pl scores_t1/threshold6_lsa gold/truth_threshold6 prcCurves_t1/prc_threshold6_lsa `;
`perl createPRC.pl scores_t1/threshold6_lta gold/truth_threshold6 prcCurves_t1/prc_threshold6_lta `;
`perl createPRC.pl scores_t1/threshold6_ltc gold/truth_threshold6 prcCurves_t1/prc_threshold6_ltc `;
`perl createPRC.pl scores_t1/threshold6_mwa gold/truth_threshold6 prcCurves_t1/prc_threshold6_mwa `;
`perl createPRC.pl scores_t1/threshold6_sbc gold/truth_threshold6 prcCurves_t1/prc_threshold6_sbc `;
`perl createPRC.pl scores_t1/threshold6_w2vCos gold/truth_threshold6 prcCurves_t1/prc_threshold6_w2vCos `;
`perl createPRC.pl gold/truth_threshold6 gold/truth_threshold6 prcCurves_t1/prc_threshold6_random --random`;

######## Threshold 6 Precision at K
`perl createPrecisionAtK.pl scores_t1/threshold6_dirCos gold/truth_threshold6 precisionAtK_t1/pak_threshold6_dirCos `;
`perl createPrecisionAtK.pl scores_t1/threshold6_freq gold/truth_threshold6 precisionAtK_t1/pak_threshold6_freq `;
`perl createPrecisionAtK.pl gold/truth_threshold6 gold/truth_threshold6 precisionAtK_t1/pak_threshold6_ideal`;
`perl createPrecisionAtK.pl scores_t1/threshold6_lsa gold/truth_threshold6 precisionAtK_t1/pak_threshold6_lsa `;
`perl createPrecisionAtK.pl scores_t1/threshold6_lta gold/truth_threshold6 precisionAtK_t1/pak_threshold6_lta `;
`perl createPrecisionAtK.pl scores_t1/threshold6_ltc gold/truth_threshold6 precisionAtK_t1/pak_threshold6_ltc `;
`perl createPrecisionAtK.pl scores_t1/threshold6_mwa gold/truth_threshold6 precisionAtK_t1/pak_threshold6_mwa `;
`perl createPrecisionAtK.pl scores_t1/threshold6_sbc gold/truth_threshold6 precisionAtK_t1/pak_threshold6_sbc `;
`perl createPrecisionAtK.pl scores_t1/threshold6_w2vCos gold/truth_threshold6 precisionAtK_t1/pak_threshold6_w2vCos `;
`perl createPrecisionAtK.pl gold/truth_threshold6 gold/truth_threshold6 precisionAtK_t1/pak_threshold6_random --random`;


print "DONE WITH ALL\n";

