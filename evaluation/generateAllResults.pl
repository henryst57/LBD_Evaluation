########################################################################################################
########################## THRESHOLD 6 Asc ################################################################
####### Threshold 6 PRC Curves
`perl createPRC.pl flippedScores/threshold6_dirCos truth/truth_threshold6 prcCurves/prc_threshold6_dirCos_asc --sortAscending`;
`perl createPRC.pl flippedScores/threshold6_freq truth/truth_threshold6 prcCurves/prc_threshold6_freq_asc --sortAscending`;
`perl createPRC.pl truth/truth_threshold6 truth/truth_threshold6 prcCurves/prc_threshold6_ideal`;
`perl createPRC.pl flippedScores/threshold6_lsa truth/truth_threshold6 prcCurves/prc_threshold6_lsa_asc --sortAscending`;
`perl createPRC.pl flippedScores/threshold6_lta truth/truth_threshold6 prcCurves/prc_threshold6_lta_asc --sortAscending`;
`perl createPRC.pl flippedScores/threshold6_ltc truth/truth_threshold6 prcCurves/prc_threshold6_ltc_asc --sortAscending`;
`perl createPRC.pl flippedScores/threshold6_mwa truth/truth_threshold6 prcCurves/prc_threshold6_mwa_asc --sortAscending`;
`perl createPRC.pl flippedScores/threshold6_sbc truth/truth_threshold6 prcCurves/prc_threshold6_sbc_asc --sortAscending`;
`perl createPRC.pl flippedScores/threshold6_w2vCos truth/truth_threshold6 prcCurves/prc_threshold6_w2vCos_asc --sortAscending`;
`perl createPRC.pl truth/truth_threshold6 truth/truth_threshold6 prcCurves/prc_threshold6_random --random`;


######## Threshold 6 Precision at K
`perl createPrecisionAtK.pl flippedScores/threshold6_dirCos truth/truth_threshold6 precisionAtK/pak_threshold6_dirCos_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores/threshold6_freq truth/truth_threshold6 precisionAtK/pak_threshold6_freq_asc --sortAscending`;
`perl createPrecisionAtK.pl truth/truth_threshold6 truth/truth_threshold6 precisionAtK/pak_threshold6_ideal`;
`perl createPrecisionAtK.pl flippedScores/threshold6_lsa truth/truth_threshold6 precisionAtK/pak_threshold6_lsa_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores/threshold6_lta truth/truth_threshold6 precisionAtK/pak_threshold6_lta_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores/threshold6_ltc truth/truth_threshold6 precisionAtK/pak_threshold6_ltc_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores/threshold6_mwa truth/truth_threshold6 precisionAtK/pak_threshold6_mwa_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores/threshold6_sbc truth/truth_threshold6 precisionAtK/pak_threshold6_sbc_asc --sortAscending`;
`perl createPrecisionAtK.pl flippedScores/threshold6_w2vCos truth/truth_threshold6 precisionAtK/pak_threshold6_w2vCos_asc --sortAscending`;
`perl createPrecisionAtK.pl truth/truth_threshold6 truth/truth_threshold6 precisionAtK/pak_threshold6_random --random`;


########################## THRESHOLD 6 Desc

####### Threshold 6 PRC Curves
`perl createPRC.pl scores/threshold6_dirCos truth/truth_threshold6 prcCurves/prc_threshold6_dirCos `;
`perl createPRC.pl scores/threshold6_freq truth/truth_threshold6 prcCurves/prc_threshold6_freq `;
`perl createPRC.pl truth/truth_threshold6 truth/truth_threshold6 prcCurves/prc_threshold6_ideal`;
`perl createPRC.pl scores/threshold6_lsa truth/truth_threshold6 prcCurves/prc_threshold6_lsa `;
`perl createPRC.pl scores/threshold6_lta truth/truth_threshold6 prcCurves/prc_threshold6_lta `;
`perl createPRC.pl scores/threshold6_ltc truth/truth_threshold6 prcCurves/prc_threshold6_ltc `;
`perl createPRC.pl scores/threshold6_mwa truth/truth_threshold6 prcCurves/prc_threshold6_mwa `;
`perl createPRC.pl scores/threshold6_sbc truth/truth_threshold6 prcCurves/prc_threshold6_sbc `;
`perl createPRC.pl scores/threshold6_w2vCos truth/truth_threshold6 prcCurves/prc_threshold6_w2vCos `;
`perl createPRC.pl truth/truth_threshold6 truth/truth_threshold6 prcCurves/prc_threshold6_random --random`;

######## Threshold 6 Precision at K
`perl createPrecisionAtK.pl scores/threshold6_dirCos truth/truth_threshold6 precisionAtK/pak_threshold6_dirCos `;
`perl createPrecisionAtK.pl scores/threshold6_freq truth/truth_threshold6 precisionAtK/pak_threshold6_freq `;
`perl createPrecisionAtK.pl truth/truth_threshold6 truth/truth_threshold6 precisionAtK/pak_threshold6_ideal`;
`perl createPrecisionAtK.pl scores/threshold6_lsa truth/truth_threshold6 precisionAtK/pak_threshold6_lsa `;
`perl createPrecisionAtK.pl scores/threshold6_lta truth/truth_threshold6 precisionAtK/pak_threshold6_lta `;
`perl createPrecisionAtK.pl scores/threshold6_ltc truth/truth_threshold6 precisionAtK/pak_threshold6_ltc `;
`perl createPrecisionAtK.pl scores/threshold6_mwa truth/truth_threshold6 precisionAtK/pak_threshold6_mwa `;
`perl createPrecisionAtK.pl scores/threshold6_sbc truth/truth_threshold6 precisionAtK/pak_threshold6_sbc `;
`perl createPrecisionAtK.pl scores/threshold6_w2vCos truth/truth_threshold6 precisionAtK/pak_threshold6_w2vCos `;
`perl createPrecisionAtK.pl truth/truth_threshold6 truth/truth_threshold6 precisionAtK/pak_threshold6_random --random`;


print "DONE WITH ALL\n";

