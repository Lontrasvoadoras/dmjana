# Etapa 08c: fígado, DM2 x remédios (GSE130991)

    contraste                                                descricao n_T2D
C0         C0                           DM2 x sem diabetes (principal)   146
C1         C1                        DM2 sem tratamento x sem diabetes    23
C2         C2             DM2 sem estatina x sem diabetes sem estatina    88
C3         C3                            DM2 tratada x DM2 não tratada   123
C3a       C3a C3 ajustado por estatina, HbA1c, glicemia de jejum e IMC   123
C3b       C3b                           C3 só em mulheres sem estatina    68
    n_ND hba1c_T2D hba1c_ND estatina_T2D estatina_ND genes_fdr05 genes_p05
C0    58      6.95     5.35           58           4         425     0.138
C1    58      6.60     5.35            3           4           0     0.049
C2    54      6.75     5.30            0           0         348     0.149
C3    23      7.10     6.60           55           3           3     0.052
C3a   23      7.10     6.60           55           3           1     0.065
C3b   20      7.00     6.60            0           0           0     0.040
    sorteados_p05 vias_fdr10 vias_p05        M6_g        M6_p     M15_g
C0          0.146          0      447  0.41518927 0.007497034 0.3927497
C1          0.045          0      445 -0.04790045 0.845811020 0.1356253
C2          0.143          0      546  0.55711171 0.001282747 0.4398388
C3          0.047          0      255  0.54372245 0.016736586 0.3079788
C3a         0.043          0      260  0.71205018 0.003056264 0.3293607
C3b         0.028          0      178  0.64653373 0.011097441 0.4247204
         M15_p colesterol_g colesterol_p
C0  0.01142087   0.68856405  0.003436426
C1  0.58192040  -0.02450265  0.920313926
C2  0.01098600   0.49237437  0.027491409
C3  0.17518981   0.84294502  0.003436426
C3a 0.17032949   0.47717919  0.030927835
C3b 0.09503145   0.63397857  0.013736341

  contraste cor_g_todos genes_principais mesmo_sentido p05_mesmo_sentido
1        C1        0.65              425           405               148
2        C2        0.94              425           425               418
3        C3        0.27              425           357                97
  razao_g_mediana
1            0.67
2            1.04
3            0.41


indefinido (perde força sem tratadas)          mantém-se sem remédio de DM2 
                                  182                                   148 
     suspeito de efeito do tratamento 
                                   95 
