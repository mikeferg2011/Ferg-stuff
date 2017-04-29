
# coding: utf-8

# In[ ]:

import numpy as np
import pandas as pd
import datetime


# In[ ]:

men = {0:'Andre',
      1:'Derrick',
      2:'Edward',
      3:'Hayden',
      4:'Jaylen',
      5:'Joey',
      6:'Michael',
      7:'Mike',
      8:'Osvaldo',
      9:'Ozzy',
      10:'Tyler'
      }

women = {0:'Alicia',
        1:'Carolina',
        2:'Cas',
        3:'Gianna',
        4:'Hannah',
        5:'Kam',
        6:'Kari',
        7:'Kathryn',
        8:'Shannon',
        9:'Taylor',
        10:'Tyranny'
        }


# In[ ]:

#weekly pairs
#weekly pairs
week1 = np.zeros((11,11))
week1[0][0] = 1
week1[1][7] = 1
week1[2][5] = 1
week1[3][8] = 1
week1[4][2] = 1
week1[5][1] = 1
week1[6][4] = 1
week1[7][6] = 1
week1[8][10] = 1
week1[9][3] = 1
week1[10][9] = 1
print week1

week2 = np.zeros((11,11))
week2[0][4] = 1
week2[1][0] = 1
week2[2][8] = 1
week2[3][9] = 1
week2[4][5] = 1
week2[5][1] = 1
week2[6][3] = 1
week2[7][2] = 1
week2[8][6] = 1
week2[9][7] = 1
week2[10][10] = 1
print week2

# In[ ]:

print datetime.datetime.now()
arrays = []
counter = 0
eye = np.eye(11)
for a in range(len(eye)):
    matrix = np.zeros((11,11))
    matrix[0] = eye[a]
    eye_a = np.delete(eye, a, 0)
    for b in range(len(eye_a)):
        print a,b,datetime.datetime.now()
        matrix[1] = eye_a[b]
        eye_b = np.delete(eye_a, b, 0)
        for c in range(len(eye_b)):
            matrix[2] = eye_b[c]
            eye_c = np.delete(eye_b, c, 0)
            for d in range(len(eye_c)):
                matrix[3] = eye_c[d]
                eye_d = np.delete(eye_c, d, 0)
                for e in range(len(eye_d)):
                    matrix[4] = eye_d[e]
                    eye_e = np.delete(eye_d, e, 0)
                    for f in range(len(eye_e)):
                        matrix[5] = eye_e[f]
                        eye_f = np.delete(eye_e, f, 0)
                        for g in range(len(eye_f)):
                            matrix[6]= eye_f[g]
                            eye_g = np.delete(eye_f, g, 0)
                            for h in range(len(eye_g)):
                                matrix[7] = eye_g[h]
                                eye_h = np.delete(eye_g, h, 0)
                                for i in range(len(eye_h)):
                                    matrix[8] = eye_h[i]
                                    eye_i = np.delete(eye_h, i, 0)
                                    for j in range(len(eye_i)):
                                        matrix[9] = eye_i[j]
                                        eye_j = np.delete(eye_i, j, 0)
                                        matrix[10] = eye_j[0]
                                        counter+=1
                                        #rules for adding to list
                                        if (matrix[3][3] == 0
										and matrix[0][0] ==0
                                        and sum(sum(matrix*week1)) == 2
										and sum(sum(matrix*week2)) == 0):
                                            arrays.append(matrix.copy())
print "total: "+str(counter)
print "remaining: "+str(len(arrays))
prob = sum(arrays)/len(arrays)
prob = pd.DataFrame(prob, index=men.values(), columns=women.values())
print prob
prob.to_csv('are_you_the_one.csv', index=True, header=True, sep=',')
print datetime.datetime.now()
