import numpy as np
import datetime

#weekly pairs
week1 = np.array([[1,0,0,0,0,0,0,0,0,0,0],
                 [0,1,0,0,0,0,0,0,0,0,0],
                 [0,0,1,0,0,0,0,0,0,0,0],
                 [0,0,0,1,0,0,0,0,0,0,0],
                 [0,0,0,0,1,0,0,0,0,0,0],
                 [0,0,0,0,0,1,0,0,0,0,0],
                 [0,0,0,0,0,0,1,0,0,0,0],
                 [0,0,0,0,0,0,0,1,0,0,0],
                 [0,0,0,0,0,0,0,0,1,0,0],
                 [0,0,0,0,0,0,0,0,0,1,0],
                 [0,0,0,0,0,0,0,0,0,0,1]])
week2 = np.array([[1,0,0,0,0,0,0,0,0,0,0],
                 [0,0,1,0,0,0,0,0,0,0,0],
                 [0,1,0,0,0,0,0,0,0,0,0],
                 [0,0,0,1,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,0,1],
                 [0,0,0,0,0,1,0,0,0,0,0],
                 [0,0,0,0,0,0,1,0,0,0,0],
                 [0,0,0,0,0,0,0,1,0,0,0],
                 [0,0,0,0,0,0,0,0,1,0,0],
                 [0,0,0,0,0,0,0,0,0,1,0],
                 [0,0,0,0,1,0,0,0,0,0,0]])


print datetime.datetime.now()
arrays = []
counter = 0
eye = np.eye(11)
for a in range(len(eye)):
    matrix = np.zeros((11,11))
    matrix[0] = eye[a]
    eye_a = np.delete(eye, a, 0)
    for b in range(len(eye_a)):
        #print a,b,datetime.datetime.now()
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
                                        if (matrix[0][0] == 1
                                        and matrix[1][1] == 0
                                        and sum(sum(matrix*week1)) == 3
                                        and sum(sum(matrix*week2)) == 4  ):
                                            arrays.append(matrix.copy())
print "total: "+str(counter)
print "remaining "+str(len(arrays))
print sum(arrays)/len(arrays)
print datetime.datetime.now()
