"""Modela os objetos do cenário 3D da fatia (casa de taipa, cajueiro e palmeira) e exporta um .glb para cada um.

Gera assets/3d/casataipa.glb, cajueiro.glb e palmeira.glb.

Uso (Blender em modo de linha de comando):
    "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --python tools/modelar_cenario.py

Cada objeto tem a origem na base (pé no chão), em metros. Cores com pequenas variações para não parecerem iguais.
"""
import math
import os
import random

import bpy

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
random.seed(1932)


def limpar_cena() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(nome: str, cor: tuple, rugosidade: float = 0.9) -> bpy.types.Material:
    mat = bpy.data.materials.new(nome)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*cor, 1.0)
    bsdf.inputs["Roughness"].default_value = rugosidade
    return mat


def variar(cor: tuple, quanto: float = 0.05) -> tuple:
    return tuple(min(1.0, max(0.0, c + random.uniform(-quanto, quanto))) for c in cor)


def caixa(nome, centro, tamanho, mat):
    bpy.ops.mesh.primitive_cube_add(size=1, location=centro)
    obj = bpy.context.active_object
    obj.name = nome
    obj.scale = tamanho
    obj.data.materials.append(mat)
    return obj


def cilindro(nome, centro, raio, altura, mat, vertices=8):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=raio, depth=altura, location=centro)
    obj = bpy.context.active_object
    obj.name = nome
    obj.data.materials.append(mat)
    return obj


def esfera(nome, centro, raio, mat):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=raio, location=centro)
    obj = bpy.context.active_object
    obj.name = nome
    obj.data.materials.append(mat)
    return obj


def unir(objetos, nome):
    """Junta as peças de um objeto num só, mantendo os materiais."""
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objetos:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objetos[0]
    bpy.ops.object.join()
    obj = bpy.context.active_object
    obj.name = nome
    return obj


def origem_na_base(obj) -> None:
    """Coloca a base do objeto no chão (z = 0), com a origem no centro da base."""
    minimo_z = min(v.co.z for v in obj.data.vertices)
    for v in obj.data.vertices:
        v.co.z -= minimo_z


def casa_taipa():
    parede = material("Taipa", variar((0.78, 0.6, 0.4)))
    telhado = material("Palha", variar((0.7, 0.55, 0.28)))
    madeira = material("Madeira", variar((0.4, 0.27, 0.16)))
    partes = [
        caixa("Paredes", (0, 0, 1.2), (3.2, 2.4, 2.4), parede),
        caixa("Porta", (0, -1.21, 0.9), (0.7, 0.05, 1.8), madeira),
        caixa("JanelaE", (-1.0, -1.21, 1.6), (0.5, 0.05, 0.5), madeira),
    ]
    # Telhado de palha: uma pirâmide achatada por cima das paredes.
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=2.5, depth=1.3, location=(0, 0, 3.05))
    telhado_obj = bpy.context.active_object
    telhado_obj.name = "Telhado"
    telhado_obj.rotation_euler.z = 0.785
    telhado_obj.data.materials.append(telhado)
    partes.append(telhado_obj)
    obj = unir(partes, "CasaTaipa")
    origem_na_base(obj)


def cajueiro():
    tronco = material("Tronco", variar((0.42, 0.28, 0.16)))
    copa = material("Copa", variar((0.33, 0.52, 0.27)))
    caju = material("Caju", variar((0.95, 0.6, 0.2)))
    partes = [cilindro("TroncoC", (0, 0, 1.0), 0.14, 2.0, tronco, vertices=6)]
    for i in range(7):
        ang = random.uniform(0, 6.28)
        dist = random.uniform(0.0, 0.9)
        partes.append(esfera(f"Copa{i}", (dist * 0.8 * random.choice([-1, 1]) * 0.7, dist * 0.5 * random.choice([-1, 1]) * 0.6, 2.4 + random.uniform(-0.2, 0.3)),
                             random.uniform(0.7, 0.95), copa))
    for i in range(10):
        partes.append(esfera(f"Caju{i}", (random.uniform(-1.2, 1.2), random.uniform(-1.0, 1.0), random.uniform(2.0, 2.9)), 0.08, caju))
    obj = unir(partes, "Cajueiro")
    origem_na_base(obj)


def palmeira():
    """Tronco fino e folhas em arco, saindo de uma coroa no topo, com cada folha feita de três segmentos."""
    tronco = material("TroncoPalma", variar((0.5, 0.38, 0.22)))
    folha = material("Folha", variar((0.25, 0.48, 0.22)))
    partes = []
    for i in range(6):
        partes.append(cilindro(f"Gomo{i}", (0.0, 0, 0.35 + i * 0.5), 0.1 - i * 0.008, 0.5, tronco, vertices=6))
    coroa = (0.0, 0, 3.1)
    for i in range(7):
        ang = i * (6.283 / 7)
        dx, dy = math.cos(ang), math.sin(ang)
        for k in range(3):
            comprimento = 0.5
            cx = coroa[0] + dx * (0.25 + comprimento * k)
            cy = coroa[1] + dy * (0.25 + comprimento * k)
            cz = coroa[2] - 0.05 * (k + 1) ** 2 * 0.5
            bpy.ops.mesh.primitive_cube_add(size=1, location=(cx, cy, cz))
            seg = bpy.context.active_object
            seg.name = f"Folha{i}_{k}"
            seg.scale = (comprimento, 0.14, 0.03)
            seg.rotation_euler = (0, math.radians(-12 - 18 * k), ang)
            seg.data.materials.append(folha)
            partes.append(seg)
    obj = unir(partes, "Palmeira")
    origem_na_base(obj)


def exportar(obj, nome: str) -> None:
    """Exporta cada objeto num arquivo próprio, para o Godot colocar onde precisar."""
    pasta = os.path.join(RAIZ, "assets", "3d")
    os.makedirs(pasta, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    caminho = os.path.join(pasta, nome + ".glb")
    bpy.ops.export_scene.gltf(filepath=caminho, export_format="GLB", use_selection=True, export_yup=True)
    print("exportado", caminho)


def main():
    for construir, nome in ((casa_taipa, "CasaTaipa"), (cajueiro, "Cajueiro"), (palmeira, "Palmeira")):
        limpar_cena()
        construir()
        exportar(bpy.data.objects[nome], nome.lower())


main()
